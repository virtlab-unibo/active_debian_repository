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
    #
    def create!
      create || raise("Errors in the package creation")
    end

    # 
    # * *Args*    :
    # * *Returns* :
    #   -
    # * *Raises* :
    #
    def files
      files_equivs = ""
      @package.items.each do |file|
        # path/appunti.txt /usr/share/unibo/course_name/appunti.txt 
        # this works on WHEEZY or higher 
        files_equivs += "#{file.attach_file_name} #{File.join(file.install_path, "")}\n\t"
      end
      files_equivs
    end

    # 
    # * *Args*    :
    # * *Returns* :
    #   -
    # * *Raises* :
    #
    def changelog_file
      if @package.changelogs.size > 0
        tfile = Tempfile.new('changelogs') 
        File.open(tfile, 'a') do |f| 
          @package.changelogs.reverse_each { |chlog| f.print chlog }
        end
        tfile.path
      else
        nil
      end
    end

    # 
    # * *Args*    :
    # * *Returns* :
    #   -
    # * *Raises* :
    #
    def copy_files(dest_dir)
      @package.items.each do |file|
        FileUtils.cp(file.attach.path, File.join(dest_dir, ""))
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
    
    #
    # * *Args*    :
    # * *Returns* :
    #   -
    # * *Raises* :
    def to_s
      # Comphrensive list of equivs options.
      # Most of them are not mandatory. Leave
      # the option nil if you don't need it.
      options = {
        :source            => nil,
        :section           => @package.section,
        :priority          => @package.priority,
        :homepage          => @package.homepage,
        :standards_version => @package.standards_version, 
        :package           => @package.name,
        :version           => @package.version,
        :maintainer        => self.maintainer, 
        :pre_depends       => @package.pre_depends,
        :depends           => @package.depends,
        :reccomends        => @package.reccomends,
        :suggests          => @package.suggests,
        :provides          => @package.provides,
        :replaces          => @package.replaces,
        :architecture      => @package.architecture,
        :copyright         => nil,
        :changelog         => self.changelog_file,
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
        if v != nil and v != "" #FIXME: we need to improve this test
          control << k.to_s.split('_').map(&:capitalize).join('-') << ": " << v << "\n"
        end
      end
      control
    end

    #
    # * *Args*    :
    # * *Returns* :
    #   -
    # * *Raises* :
    def maintainer
        "#{@package.maintainer} <#{@package.email}>"
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
    #   - +tmp_dir+ -> where to put the control file during the build. 
    # * *Returns* :
    #   -
    # * *Raises* :
    def control_file(tmp_dir)
      File.join(tmp_dir, "#{@package.name}-control")
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
