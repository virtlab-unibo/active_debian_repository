require 'tmpdir'

module ActiveDebianRepository
  class Equivs

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
      File.join(@dest_dir, self.package_filename)
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

    #
    # * *Args*    :
    # * *Returns* :
    #   -
    # * *Raises* :
    def files
      files_equivs = ""
      @package.items.each do |file|
        # path/appunti.txt /usr/share/unibo/course_name/appunti.txt 
        # this works on WHEEZY or higher 
        puts 
        files_equivs += "#{file.attach_file_name} #{File.join(file.install_path, "")}\n\t"
      end
      files_equivs
    end


    def copy_files dest_dir
      @package.items.each do |file|
        puts "cp #{file.attach.path} #{File.join(dest_dir,"")}"
        FileUtils.cp(file.attach.path, File.join(dest_dir, ""))
      end
    end

    #
    # * *Args*    :
    # * *Returns* :
    #   -
    # * *Raises* :
    # FIXME: Delete it 
    #def format_description (short_description, long_description="")
    #  res = short_description
    #  long_description.each_line do |line|
    #    if line.strip.empty?
    #      res << " .\n"
    #    else
    #      res << " #{line}"
    #    end
    #  end
    #  res.strip
    #end

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
    
    def to_s
      # Comphrensive list of equivs options.
      # Most of them are not mandatory. Leave
      # the option nil if you don't need it.
      options = {
        :source            => nil,
        :section           => @package.section,
        :priority          => "optional",
        :homepage          => @package.homepage,
        :standards_version => "3.9.2",
        :package           => @package.name,
        :version           => @package.version,
        :maintainer        => self.maintainer, 
        :pre_depends       => nil,
        :depends           => nil,
        :reccomends        => nil,
        :suggests          => nil,
        :provides          => nil,
        :replaces          => nil,
        :architecture      => "all",
        :copyright         => nil,
        :changelog         => nil,
        :readme            => nil,
        :postinst          => self.postinst,
        :preinst           => self.preinst,
        :postrm            => self.postrm,
        :prerm             => self.prerm,
        :extra_files       => nil,
        :files             => self.files,
        :description       => self.description 
      }
      control = ""
      options.each do |k, v|
        if v != nil and v != "" #FIXME: we definitely need to improve this test.
          control << k.to_s.split('_').map(&:capitalize).join('-') << ": " << v << "\n"
        end
      end
      puts control
      control
    end

    #
    # * *Args*    :
    # * *Returns* :
    #   -
    # * *Raises* :
    def maintainer
      if @package.class.method_defined? :email and @package.email 
        "#{@package.maintainer} <#{@package.email}>"
      else
        "#{@package.maintainer} <dummy@email-not-provided.no>"
      end
    end

    #
    # * *Args*    :
    # * *Returns* :
    #   -
    # * *Raises* :
    def package_filename
      "#{@package.name}_#{@package.version}_#{@package.architecture}.deb"
    end

    #
    # * *Args*    :
    # * *Returns* :
    #   -
    # * *Raises* :
    def postrm
      @package.get_script :postrm

    end

    #
    # * *Args*    :
    # * *Returns* :
    #   -
    # * *Raises* :
    def prerm
      @package.get_script :prerm
    end

    #
    # * *Args*    :
    # * *Returns* :
    #   -
    # * *Raises* :
    def postinst
      @package.get_script :postinst
    end

    #
    # * *Args*    :
    # * *Returns* :
    #   -
    # * *Raises* :
    def preinst
      @package.get_script :preinst
    end

    #
    # * *Args*    :
    # * *Returns* :
    #   -
    # * *Raises* :
    def name
      @package.name.gsub(' ', '-') # not really necessary
    end

    #
    # * *Args*    :
    # * *Returns* :
    #   -
    # * *Raises* :
    #
    def depends
      @package.depends
    end
    #
    # * *Args*    :
    #   - +tmp_dir+ -> where to put the control file during the build. 
    # * *Returns* :
    #   -
    # * *Raises* :
    def control_file(tmp_dir)
      File.join(tmp_dir, "#{self.name}-control")
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
        f.puts self.to_s # control_string 
        ActiveRecord::Base.logger.debug self.to_s #control_string 
      end

      # run equivs-build
      Dir.chdir(tmp_dir) do
        File.exists?(EQUIVS_BUILD_COMMAND) or raise "executable equivs-build missing"
        res = `#{EQUIVS_BUILD_COMMAND} #{self.control_file(tmp_dir)} 2>&1`
        ActiveRecord::Base.logger.debug "#{EQUIVS_BUILD_COMMAND} returns #{res}"
        if $?.success?
          # mv can raise
          FileUtils.mv(self.package_filename, @dest_dir, :force => true)
        else
          ActiveRecord::Base.logger.debug "Equivs-build failed"
          raise "Equivs-build failed"
        end
      end
    end

  end
end	
