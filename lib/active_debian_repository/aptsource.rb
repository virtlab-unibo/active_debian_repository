module ActiveDebianRepository
  module AptSource

    ARCH_LIST = ['binary-amd64', 'binary-i386', 'source']
    BUNZIP2 = '/bin/bunzip2 -q'
    GUNZIP = '/bin/gunzip -q'

    def act_as_apt_source(options={})
      include InstanceMethods
      logger.info "Inizialized as act_as_debian_source"
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
      def update_db(package_file)
        # Hash of name => version
        old_packages = self.packages.select([:name, :version]).inject({}){|res, p| res[p.name] = p.version; res}

        ActiveDebianRepository::Parser.new(package_file).each do |p|
          if old_package_version = old_packages.delete(p['package']) # already there
            if old_package_version != p['version'] # different version... we need to update it
              self.packages.where(:name => p['package']).first.update_attributes(ActiveDebianRepository::Parser.db_attributes(p)) or raise p.inspect
            end
          else # we need to add it
            self.packages.create!(ActiveDebianRepository::Parser.db_attributes(p))
          end
        end
        self.packages.where(:name => old_packages.keys).delete_all
      end

      #
      # * *Args*    :
      # * *Returns* :
      #   - 
      # * *Raises* :
      #
      def update_db_from_net
        packages_file = Tempfile.new('Packages', '/tmp')
        begin
          `wget -q "#{self.safe_url('bz2')}" -O - | #{BUNZIP2} > #{packages_file.path}`
          `wget -q "#{self.safe_url('gz')}" -O - | #{GUNZIP} > #{packages_file.path}` unless $?.success?
          update_db(packages_file)
        ensure
          packages_file.close
          packages_file.unlink
        end
      end

    end
  end
end
