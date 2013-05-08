module ActiveDebianRepository
  module AptSource

    ARCH_LIST = ['binary-amd64', 'binary-i386', 'source']
    BUNZIP2 = '/bin/bunzip2 -q'
    GUNZIP = '/bin/gunzip -q'

    def acts_as_apt_source(options={})
      include InstanceMethods

      attr_accessor :spawn

      logger.info "Inizialized as acts_as_debian_source"
    end

    module InstanceMethods
      # default Packages.bz2 ma si puo' passare il gz o altra estensione
      # FIXME we need to change the name of the  method:
      # something like packages_url or packages_index_url
      #
      # * *Args*    :
      # * *Returns* :
      #   - 
      # * *Raises* :
      #
      def url(ext = 'bz2')
        base = "#{self.uri}/dists/#{self.distribution}/#{self.component}/#{self.arch}"
        base += ((arch.eql? "source") ? "/Sources.#{ext}" :  "/Packages.#{ext}")
      end

      # TODO for using is shell (wget)
      #
      # * *Args*    :
      # * *Returns* :
      #   - 
      # * *Raises* :
      #
      def safe_url(ext = 'bz2')
        url(ext)
      end

      def to_s
        "#{((arch.eql? "source") ? "deb-src" : "deb")} #{self.uri} #{self.distribution} #{self.component}"
      end

      # It suppose that the package file is ordered
      # (Downloaded from debian repos).
      #
      # * *Args*    :
      # * *Returns* :
      #   - 
      # * *Raises* :
      #
      def update_db(packages_file)
        # Hash of name => version
        old_packages = self.packages.select([:name, :version]).inject({}){|res, p| res[p.name] = p.version; res}

        ActiveDebianRepository::Parser.new(packages_file).each do |p|
          if old_package_version = old_packages.delete(p['package']) # already there
            if old_package_version != p['version'] # different version... we need to update it
              self.packages.where(:name => p['package']).first.update_attributes(ActiveDebianRepository::Parser.db_attributes(p)) or raise p.inspect
            end
          else # we need to add it
            self.packages.create!(ActiveDebianRepository::Parser.db_attributes(p))
          end
        end
        self.packages.where(:name => old_packages.keys).delete_all unless old_packages.keys.empty?
      end

      #
      # * *Args*    :
      # * *Returns* :
      #   - 
      # * *Raises* :
      #
      def update_db_from_net(background = nil)
        packages_file = "/tmp/Packages_#{Random.new_seed}"
        `wget -q "#{self.safe_url('bz2')}" -O - | #{BUNZIP2} > #{packages_file}`
        `wget -q "#{self.safe_url('gz')}" -O - | #{GUNZIP} > #{packages_file}` unless $?.success?
        background ? update_db_in_background(packages_file) : update_db(packages_file)
        # TODO FIXME
        # File.unlink(packages_file)
      end

      #
      # * *Args*    :
      # * *Returns* :
      #   - 
      # * *Raises* :
      #
      def update_db_in_background(packages_file)
        # FIXME
        if update_db_running?
          logger.info("AptSource already updating for #{self.inspect}: #{@spawn.inspect}")
          return true
        end
        logger.info ("In update_db_in_background")
        @spawn = Spawnling.new() do
          logger.info("in spawn before running update_db") 
          update_db(packages_file)
        end
      end

      def update_db_running?
        return false unless @spawn
        Spawnling.alive?(@spawn.handle)
      end
    end
  end
end
