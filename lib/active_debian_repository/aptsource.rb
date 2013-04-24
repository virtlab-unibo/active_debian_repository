module ActiveDebianRepository
  module AptSource

    ARCH_LIST = ['binary-amd64', 'binary-i386', 'source']
    WGET = '/usr/bin/wget'
    BUNZIP2 = '/bin/bunzip2 -q'
    GUNZIP = '/bin/gunzip -q'

    def act_as_apt_source(options={})
      include InstanceMethods
      logger.info "Inizialized as act_as_debian_source"
    end

    module InstanceMethods
      # default Packages.bz2 ma si puo' passare il gz o altra estensione
      # FIXME change name to method.
      # something like packages_url or packages_index_url
      def url(ext = 'bz2')
        base = "#{self.uri}/dists/#{self.distribution}/#{self.component}/#{self.arch}"
        base += ((arch.eql? "source") ? "/Sources.#{ext}" :  "/Packages.#{ext}")
      end

      # TODO for using is shell (wget)
      def safe_url(ext = 'bz2')
        url(ext)
      end

      def to_s
        "#{((arch.eql? "source") ? "deb-src" : "deb")} #{self.uri} #{self.distribution} #{self.component}"
      end

      # suppongo che il package file sia ordinato (scaricato da debian)
      def update_db(package_file)
        # Hash di name => version
        old_packages = self.packages.select([:name, :version]).inject({}){|res, p| res[p.name] = p.version; res}

        ActiveDebianRepository::Parser.new(package_file).each do |p|
          if old_package_version = old_packages.delete(p['package']) # c'era anche prima
            if old_package_version != p['version'] # versione diversa.... da aggiornare
              self.packages.where(:name => p['package']).first.update_attributes(ActiveDebianRepository::Parser.db_attributes(p)) or raise p.inspect
            end
          else # da aggiungere
            self.packages.create!(ActiveDebianRepository::Parser.db_attributes(p))
          end
        end
        self.packages.where(:name => old_packages.keys).delete_all
      end

      def update_db_from_net
        packages_file = Tempfile.new('Packages', '/tmp') 
        begin
          logger.info %Q^"#{WGET} -q "#{self.safe_url('bz2')}" -O - | #{BUNZIP2} > #{packages_file.path}"^
          logger.info %Q^"or #{WGET} -q "#{self.safe_url('gz')}" -O - | #{GUNZIP} > #{packages_file.path}"^
          `#{WGET} -q "#{self.safe_url('bz2')}" -O - | #{BUNZIP2} > #{packages_file.path}`
          `#{WGET} -q "#{self.safe_url('gz')}" -O - | #{GUNZIP} > #{packages_file.path}` unless $?.success?
          update_db(packages_file)
        ensure
          packages_file.close
          packages_file.unlink  
        end
      end

    end
  end
end


