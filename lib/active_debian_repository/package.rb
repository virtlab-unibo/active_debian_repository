require 'tmpdir'

module ActiveDebianRepository
module Package
  
  # options: 
  #   :homepage_proc => lambda {|p| "http://www.example.it/packages/#{p.name}"},
  #   :install_dir base di destinazione del file dopo dpkg -i
  #   :repo_dir    dove si salva il file deb per il server web
  def act_as_debian_package(options={})

    # Declare a class-level attribute whose value is inheritable by subclasses. 
    # Subclasses can change their own value and it will not impact parent class.
    class_attribute :package_options

    # name must consist only of lower case letters (a-z), digits (0-9), plus (+) and minus (-) signs, and periods (.). 
    # They must be at least two characters long and must start with an alphanumeric character.
    validates_format_of :name, :with => /^[a-z0-9][a-z0-9+.-]+$/, :message => :package_name_format

    self.package_options = {
      :section        => 'debutils',
      :homepage_proc  => lambda {|p| "http://localhost/debutils/#{p.name}"},
      :install_dir    => '/usr/share/debutils', # base di destinazione del file dopo dpkg -i
      :repo_dir       => '/var/www/public',
      :maintainer     => 'Maintainer',
      :email          => 'debutils@example.com',
      :core_dep       => 'vlab-core',        # dipendenza comune a tutti
      :tmp_dir        => '/var/www/tmp',
      :hide_depcore   => true                # nascondi dipendenza
    }.merge(options)

    include InstanceMethods
    logger.info "Initialized as act_as_debian_package"
  end

  module InstanceMethods
    def to_s
      self.name
    end
    
    # package.has_depend?('vlan')
    def has_depend?(package_name)
      self.depends.split(', ').map{|n| n.split[0]}.include?(package_name) if self.depends
    end

    # package.add_files('vlan') or with version package.add_files('vlan', "23.4")
    def add_depend(package_name, versions = nil)
      if self.has_depend?(package_name)
        self.errors.add(:base, "Pacchetto gia` incluso")
        return false
      end
      if self.class.where(:name => package_name).count > 0
        self.depends += ", " unless self.depends.blank?
        self.depends += package_name
        self.depends += " (#{versions})" if versions
      else
        self.errors.add(:base, "Pacchetto #{package_name} sconosciuto")
        return false
      end
      self.save
    end

    def remove_depend(package_name)
      self.depends = self.depends.split(', ').delete_if{|a| a.split[0] == package_name}.join(', ')
      self.save
    end

    # return array of packages it depends on
    def depends_on
      self.depends.split(', ').inject([]) do |res, name|
        res << self.class.where(:name => name.split(/ /)[0]).first unless (package_options[:hide_depcore] and name == package_options[:core_dep])  
        res
      end
    end

    def add_files(files)
      @files = files
    end

    # generates the homepage from option homepage_proc
    def generate_homepage 
      self.homepage = package_options[:homepage_proc].call(self)
    end

    def maintainer
       "#{package_options[:maintainer]} <#{package_options[:email]}>"
    end

    def section
      package_options[:section]
    end

    def repo_dir
      package_options[:repo_dir]
    end

    def install_dir
      package_options[:install_dir]
    end

    def deb_file_name
      "#{self.name}_#{self.version}_all.deb"
    end

    # Return deb file name or raise in case of errors
    def create_deb!(repo_dir = nil)
      create_deb(repo_dir) || raise("create_deb! in debutils::package.rb has raised an exception")
    end

    # Return deb file name or false in case of errors
    def create_deb(repo_dir = nil)
      DebPckFile.new(self, repo_dir).create
    end

    def scripts
      @scripts ||= {}
    end

    def add_script (type, content)
      self.scripts[type] = content
    end

  end
end
end

