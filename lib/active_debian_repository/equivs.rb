require 'tmpdir'

module ActiveDebianRepository
  class Equivs

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
          package_build!(tmp_dir)
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
      @package.documents.each do |file|
        ActiveRecord::Base.logger.info("#{file.attach_file_name} #{file.install_path}")
        files_equivs += "#{file.attach_file_name} #{file.install_path}\n\t"
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
      tfile = Tempfile.new('changelogs') 
      if @package.changelogs.size > 0
        File.open(tfile, 'a') do |f| 
          @package.changelogs.reverse_each { |chlog| f.puts chlog }
        end
      else
        ActiveRecord::Base.logger.debug "Creating a fake changelog."
        fake_chlog = @package.changelogs.new 
        @package.changelogs = []
        fake_chlog.package = @package
        fake_chlog.version = @package.version
        File.open(tfile, 'a') { |f| f.puts fake_chlog.to_s  }
      end
      tfile.path
    end

    # 
    # * *Args*    :
    # * *Returns* :
    #   -
    # * *Raises* :
    #
    def copyright_file
      if @package.copyright and @package.copyright != ""
        tfile = Tempfile.new('copyright') 
        File.open(tfile, 'w') { |f| f.puts @package.copyright }
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
    def readme_file
      if @package.readme and @package.readme != ""
        tfile = Tempfile.new('readme') 
        File.open(tfile, 'w') { |f| f.puts @package.readme }
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
      @package.documents.each do |file|
        ActiveRecord::Base.logger.debug "copying file #{file.attach.path} in #{File.join(dest_dir, "")}"
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
        :source            => nil, # probably we'll never implement it
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
        :copyright         => self.copyright_file,
       # :changelog         => self.changelog_file,
        :readme            => self.readme_file,
        :postinst          => self.postinst,
        :preinst           => self.preinst,
        :postrm            => self.postrm,
        :prerm             => self.prerm,
        :extra_files       => nil, # probably we'll never implement it
        :files             => self.files,
        :description       => self.description 
      }
      control = ""
      options.each do |k, v|
        if v != nil and v != "" #TODO: think if this test needs to be improved 
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
    # * *Args*    
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
    def package_build!(tmp_dir)
      # copying template files
      FileUtils.cp_r(File.expand_path(File.join(File.dirname(__FILE__), "debian")), tmp_dir)
      Dir.chdir(tmp_dir) do
        ppath = File.join("..", self.package_filename)
        File.delete(ppath) if File.exists? ppath
        res = run_dpkg tmp_dir, @package.gpg_key 
        if res or File.exists? ppath 
          # mv can raise
          FileUtils.mv(ppath , @dest_dir, :force => true)
        else
          ActiveRecord::Base.logger.debug "Dpkg-buildpackage failed"
          raise "dpkg-buildpackage failed"
        end
      end
    end


    # runs dpkg-buildpackage 
    #
    # * *Args*    :
    #   - +k_id+ -> GPG Key id to sign .changes and .dsc 
    # * *Returns* :
    # True if dpkg-buildpackage returns 0
    # False otherwise.
    # dpkg-buildpackage returns a value different
    # from 0 even if it can't signed the package.
    # In that case the package is successfully created.
    #   -
    def run_dpkg tmp_dir, k_id
      self.populate_package tmp_dir
      (key = "-k#{k_id}") unless k_id == ""
      stdout = `dpkg-buildpackage -rfakeroot #{key} 2>&1`
      ActiveRecord::Base.logger.debug stdout 
      if $?.success?
        true
      else
        false
      end 
    end

    def populate_package package_dir
      options = {
        :copyright         => self.copyright_file,
        :changelog         => self.changelog_file,
        :readme            => self.readme_file,
        :postinst          => self.postinst,
        :preinst           => self.preinst,
        :postrm            => self.postrm,
        :prerm             => self.prerm
      }
      options.each do |k, v|
        ActiveRecord::Base.logger.debug "copying #{v} in #{File.join(package_dir, "debian/#{k}")}" 
        FileUtils.cp(v, File.join(package_dir, "debian/#{k}")) unless (v == nil or v == "")
      end
      if self.files != ""
        ActiveRecord::Base.logger.debug "Writing files in debian/install" 
        File.open(File.join(package_dir, "debian/install"), 'w') { |file| file.write(self.files.strip) }
      end
      ActiveRecord::Base.logger.debug "Writing control file" 
      File.open(File.join(package_dir, "debian/control"), 'w+') { |file| file.write(self.control) }
    end

    def control
      
      options = {
        :source            => @package.name, # probably we'll never implement it
        :section           => @package.section,
        :priority          => @package.priority,
        :build_depends     => "debhelper (>= 7)",
        :maintainer        => self.maintainer,
        :homepage          => @package.homepage,
        :standards_version => @package.standards_version + "\n", 
        :package           => @package.name,
        :architecture      => @package.architecture,
        :pre_depends       => @package.pre_depends,
        :depends           => @package.depends,
        :reccomends        => @package.reccomends,
        :suggests          => @package.suggests,
        :provides          => @package.provides,
        :replaces          => @package.replaces,
        :description       => self.description 
      }
      res = ""
      options.each do |k, v|
        if v != nil and v != "" #TODO: think if this test needs to be improved 
          res << k.to_s.split('_').map(&:capitalize).join('-') << ": " << v << "\n"
        end
      end
      res
    end

  end
end	
