require 'tmpdir'

module ActiveDebianRepository
  class Equivs

    PRIORITY     = "optional"
    ARCHITECTURE = "all"
    STD_VERSION  = "3.6.2"
    EQUIVS_BUILD_COMMAND = "/usr/bin/equivs-build"

    # deb = Equivs.new(package, dest_dir)
    # example Equivs.new(package, '/var/www/debian/virtlab')
    #
    # * *Args*    :
    #   - +package+ -> Package object
    #   - +dest_dir+ -> where to put the package after the build. 
    # * *Returns* :
    #   -
    # * *Raises* :
    #   - ++ ->
    #  
    def initialize(package, dest_dir)
      @package  = package
      @dest_dir = dest_dir
    end

    # Create debian package file (copy files and exec equiv_build)
    # Return it's file name or false in case of errors
    #
    # * *Args*    :
    # * *Returns* :
    #   -
    # * *Raises* :
    #
    def create
      begin
        Dir.mktmpdir do |tmp_dir|
          copy_files(tmp_dir)
          equivs_build!(tmp_dir)
        end
      rescue => err
        ActiveRecord::Base.logger.info("ERROR in Equivs.create: #{err}")
        return false
      end
      File.join(@dest_dir, @package.deb_file_name)
    end

    # Create debian package file (copy files and exec equiv_build)
    # Return it's file name or raise in case of errors
    #
    # * *Args*    :
    # * *Returns* :
    #   -
    # * *Raises* :
    def create!
      create || raise("Errors in the package creation")
    end

    # copy files (@file = @package.documents) in tmp_dir and fill
    # @files_equivs_string the string relative to file in equivs-control
    #
    # * *Args*    :
    #   - +tmp_dir+ -> where to put the files during the build. 
    # * *Returns* :
    #   -
    # * *Raises* :
    def copy_files(tmp_dir)
      @files_equivs_string = @package.items.empty? ? "# Files" : "Files: "
      @package.items.each do |file|
        FileUtils.cp(file.attach.path, tmp_dir)
        # appunti.txt /usr/share/unibo/course_name/appunti.txt 
        # this works on WHEEZY or higher (see git checkout squeeze)
        @files_equivs_string += "#{file.attach_file_name} #{file.install_path}\n\t"
      end
    end

    #
    # * *Args*    :
    # * *Returns* :
    #   -
    # * *Raises* :
    def description
      res = (@package.short_description ? @package.short_description : "Description not available") + "\n"
      return res unless @package.long_description
      @package.long_description.each_line do |line|
        if line.strip.empty?
          res << " .\n"
        else
          res << " #{line}"
        end
      end
      res.strip
    end

    # format the script list in order to add
    # it to the equivis control file
    #
    # * *Args*    :
    # * *Returns* :
    #   -
    # * *Raises* :
    def scripts_string 
      scripts_str = ""
      @package.scripts.each do |script|
        #FileUtils.cp(script.attach.path, tmp_dir)
        scripts_str += "#{script.stype.to_s.capitalize}: #{script.attach.path}\n"
      end
      scripts_str.strip 
    end

    # TODO refactor with some template method
    # Description: <single line synopsis>
    #  <extended description over several lines>
    #  http://www.debian.org/doc/debian-policy/ch-controlfields.html#s-f-Description
    #
    # * *Args*    :
    # * *Returns* :
    #   -
    # * *Raises* :
    def control_string 
      %Q[Section: #{@package.section}
Priority: #{PRIORITY}
Homepage: #{@package.homepage}
Standards-Version: #{STD_VERSION}

Package: #{@package.name}
Version: #{@package.version}
Maintainer: #{self.maintainer_line}
Depends: #{@package.depends}
Architecture: #{ARCHITECTURE}
#{scripts_string}
#{@files_equivs_string}
Description: #{self.description}
]
    end

    #
    # * *Args*    :
    #   - +package+ -> Package object
    #   - +dest_dir+ -> where to put the package after the build. 
    # * *Returns* :
    #   -
    # * *Raises* :
    def maintainer_line
      "#{@package.maintainer} <#{@package.email}>"
    end

    #
    # * *Args*    :
    #   - +tmp_dir+ -> where to put the control file during the build. 
    # * *Returns* :
    #   -
    # * *Raises* :
    def control_file(tmp_dir)
      clean_name = @package.name.gsub(' ', '-') # not really necessary
      File.join(tmp_dir, "#{clean_name}-control")
    end

    # runs equivs build
    #
    # * *Args*    :
    #   - +tmp_dir+ -> where to put the package during the build. 
    # * *Returns* :
    #   -
    # * *Raises* :
    def equivs_build!(tmp_dir)
      # create equivs_control file
      File.open(control_file(tmp_dir), 'w') do |f|
        f.puts control_string 
        ActiveRecord::Base.logger.debug control_string 
      end

      # run equivs-build
      Dir.chdir(tmp_dir) do
        File.exists?(EQUIVS_BUILD_COMMAND) or raise "executable equivs-build missing"
        res = `#{EQUIVS_BUILD_COMMAND} #{self.control_file(tmp_dir)} 2>&1`
        ActiveRecord::Base.logger.debug "#{EQUIVS_BUILD_COMMAND} returns #{res}"
        if $?.success?
          # mv can raise
          FileUtils.mv(@package.deb_file_name, @dest_dir, :force => true)
        else
          ActiveRecord::Base.logger.debug "Equivs-build failed"
          raise "Equivs-build failed"
        end
      end
    end

  end
end	
