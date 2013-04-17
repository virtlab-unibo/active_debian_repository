require 'tmpdir'

module ActiveDebianRepository
module Package
  
  # options: 
  #   :homepage_proc => lambda {|p| "http://www.example.it/packages/#{p.name}"},
  def act_as_debian_package(options={})

    # Declare a class-level attribute whose value is inheritable by subclasses. 
    # Subclasses can change their own value and it will not impact parent class.
    class_attribute :package_options

    # name must consist only of lower case letters (a-z), digits (0-9), plus (+) and minus (-) signs, and periods (.). 
    # They must be at least two characters long and must start with an alphanumeric character.
    validates_format_of :name, :with => /^[a-z0-9][a-z0-9+.-]+$/, :message => :package_name_format

    self.package_options = {
      :section        => 'Misc',
      :homepage_proc  => lambda {|p| "http://localhost/debutils/#{p.name}"},
      :maintainer     => 'Maintainer',
      :email          => 'debutils@example.com',
      :tmp_dir        => '/var/www/tmp'
      
    }.merge(options)

    include InstanceMethods
    logger.info "Initialized as act_as_debian_package"
  end

  module InstanceMethods
    def to_s
      self.name
    end
    
    # package.depends_on?('vlan')
    def depends_on?(package_name)
      self.depends.split(', ').map{|n| n.split[0]}.include?(package_name) if self.depends
    end

    # package.add_dependency('vlan') or with version package.add_dependency('vlan', "23.4")
    def add_dependency(package_name, versions = nil)
      if self.depends_on?(package_name)
        self.errors.add(:base, "Dependency already present")
        return false
      end
      if self.class.where(:name => package_name).count > 0
        self.depends += ", " unless self.depends.blank?
        self.depends += package_name
        self.depends += " (#{versions})" if versions
      else
        self.errors.add(:base, "Unknown package #{package_name}")
        return false
      end
      self.save
    end

    def remove_dependency(package_name)
      self.depends = self.depends.split(', ').delete_if{|a| a.split[0] == package_name}.join(', ')
      self.save
    end

    # FIXME: maybe we should rename it: dependencies
    # return array of packages it depends on
    def depends_on
      self.depends.split(', ').inject([]) do |res, name|
        res << self.class.where(:name => name.split(/ /)[0]).first  
        res
      end
    end

    #def add_files(files)
    #  @files = files
    #end

    # generates the homepage from option homepage_proc
    def homepage 
      package_options[:homepage_proc].call(self)
    end

    def maintainer
       "#{package_options[:maintainer]}"
    end

    def section
      package_options[:section]
    end

    def email
      package_options[:email]
    end

    def deb_file_name
      "#{self.name}_#{self.version}_all.deb"
    end

    #FIXME: Equivs.new(package, dest_dir).create should be called
    # from the package_controller. Commented out create_deb methods below.

    # Return deb file name or raise in case of errors
    #def create_deb!(dest_dir= nil)
    #  create_deb(dest_dir) || raise("create_deb! in debutils::package.rb has raised an exception")
    #end

    # Return deb file name or false in case of errors
    #def create_deb(dest_dir = nil)
    #  Equivs.new(self, dest_dir).create
    #end

    #FIXME: scripts has its own table in the db.
    def scripts
      @scripts ||= {}
    end

    def add_script (type, content)
      self.scripts[type] = content
    end

  end
end
end

