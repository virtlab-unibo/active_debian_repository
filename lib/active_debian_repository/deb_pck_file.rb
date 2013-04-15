require 'tmpdir'

module ActiveDebianRepository
  class DebPckFile

    PRIORITY     = "optional"
    ARCHITECTURE = "all"
    STD_VERSION  = "3.6.2"
    EQUIVS_BUILD_COMMAND = "/usr/bin/equivs-build"

    # deb = DebPckFile.new(package, repo_dir = nil)
    # example DebPckFile.new(package, 'var/www/debian/virtlab')
    # in case repo_dir is nil package.repo_dir is used
    def initialize(package, repo_dir = nil)
      @package  = package
      @repo_dir = repo_dir || @package.repo_dir
      @files    = @package.documents
      @scripts  = @package.scripts
      # base dir after dpkg -i (ex: /usr/share/unibo)
      @install_dir = @package.install_dir
      # where files (package.documents will end after dpkg -i (ex: /usr/share/unibo/corso_davoli)
      @files_install_dir = File.join(@install_dir, @package.name)
      ActiveRecord::Base.logger.debug("inizializzato DebPkg di #{@package} in #{@install_dir}")
    end

    # Create debian package file (copy files and exec equiv_build)
    # Return it's file name or false in case of errors
    def create
      begin
        Dir.mktmpdir do |tmp_dir|
          copy_files(tmp_dir)
          equivs_build(tmp_dir)
        end
      rescue => err
        ActiveRecord::Base.logger.info("ERRORE in DebPckFile.create!: #{err}")
        return false
      end
      File.join(@repo_dir, @package.deb_file_name)
    end

    # Create debian package file (copy files and exec equiv_build)
    # Return it's file name or raise in case of errors
    def create!
        create || raise("Errors in the package creation")
    end

    # copy files (@file = @package.documents) in tmp_dir and fill
    # @files_equivs_string the string relative to file in equivs-control
    def copy_files(tmp_dir)
      @files_equivs_string = @files.empty? ? "# Files" : "Files: "
      @files.each do |document|
        FileUtils.cp(document.attach.path, tmp_dir)
        # appunti.txt /usr/share/unibo/course_name/appunti.txt 
        # this works on WHEEZY or higher (see git checkout squeeze)
        @files_equivs_string += "#{document.attach_file_name} #{@files_install_dir}\n\t"
      end
    end

=begin
  Description: <short description>
               <long description>
               The format for the package description is a short brief  summary
               on the first line (after the "Description" field). The following
               lines should be used as a  longer,  more  detailed  description.
               Each  line  of the long description must be preceded by a space,
               and blank lines in the long description must  contain  a  single
               '.' following the preceding space.
=end
    # body is the long description. Union of descirtion (unfortunate name) and body. 
    def description
      res = (@package.description ? @package.description : "Descrizione non fornita.") + "\n"
      return res unless @package.body
      @package.body.each_line do |line|
        if line.strip.empty?
          res << " .\n"
        else
          res << " #{line}"
        end
      end
      res.strip
    end

    # {:postint => 'ciao.sh', :preinst => ...}
    def scripts_string
      scripts_str = ""
      @scripts.each do |type, filename|
        scripts_str += "#{type.to_s.capitalize}: #{filename}\n"
      end
      scripts_str.strip 
    end

    # TODO refactor with some template method
    # Description: <single line synopsis>
    #  <extended description over several lines>
    #  http://www.debian.org/doc/debian-policy/ch-controlfields.html#s-f-Description
    def control_string
      %Q[Section: #{@package.section}
Priority: #{PRIORITY}
Homepage: #{@package.homepage}
Standards-Version: #{STD_VERSION}

Package: #{@package.name}
Version: #{@package.version}
Maintainer: #{@package.maintainer}
Depends: #{@package.depends}
Architecture: #{ARCHITECTURE}
#{scripts_string}
#{@files_equivs_string}
Description: #{self.description}
]
    end

    def control_file(tmp_dir)
      clean_name = @package.name.gsub(' ', '-') # not really necessary
      File.join(tmp_dir, "#{clean_name}-control")
    end

    # runs equivs build
    # dir = directory temporanea
    def equivs_build(tmp_dir)
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
          #ActiveRecord::Base.logger.debug "moving #{@package.deb_file_name} in #{@repo_dir}"
          mv_pkg_into_repo   
        else
          ActiveRecord::Base.logger.debug "Equivs-build failed"
        end
      end
    end

    # Move the just created package into the repo
    #
    def mv_pkg_into_repo
      # max number of attemps
      lock_available = false
      attemps_limit = 5
      attemps = 0
      begin
        while (not lock_available) && (attemps < attemps_limit) do
          begin
            attemps = attemps + 1
            ActiveRecord::Base.logger.debug "Attemps number #{attemps} of getting the lock.."
            Dir.mkdir("/var/lock/updaterepo.lock")
            ActiveRecord::Base.logger.debug "lock obtained"
            ## CRITICAL SECTION
            lock_available = true # exit the loop even if the mv will fail
            ActiveRecord::Base.logger.info "moving the #{@package.deb_file_name} in #{@repo_dir}."
            # mv the package into the destination directory
            FileUtils.mv(@package.deb_file_name, @repo_dir, :force => true)
            ## END CRITICAL SECTION
          rescue SystemCallError => e
            # we obtained the lock but something went wrong (the package has been 
            # created but not as we expected) in the build of the package.
            if lock_available
              ActiveRecord::Base.logger.info "Failed to move the #{@package.deb_file_name} file."
              raise "ERROR: Failed to move the #{@package.deb_file_name} file."
            else	
              ActiveRecord::Base.logger.info "Already locked. Attemps n. #{attemps}"
              sleep(1)
            end
          end
        end
      ensure 
        if attemps == attemps_limit
          ActiveRecord::Base.logger.info "ERROR: Reached max number of attemps. Failed to get the lock." 
          raise "ERROR: Reached max number of attemps. Failed to get the lock." 
        else
          Dir.rmdir("/var/lock/updaterepo.lock")
          ActiveRecord::Base.logger.debug "rm /var/lock/updaterepo.lock"
        end
      end
    end	

  end
end
