require 'tmpdir'
require 'tempfile'

module ActiveDebianRepository
module Package

  # options:
  #   :homepage_proc => lambda {|p| "http://www.example.it/packages/#{p.name}"},
  def acts_as_debian_package(options={})

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
      :email          => 'debutils@example.com'
    }.merge(options)

    include InstanceMethods
    logger.info "Initialized as acts_as_debian_package"
  end

  module InstanceMethods
    def to_s
      self.name
    end

    # package.depends_on?('vlan')
    #
    # * *Args*    :
    #   - +package_name+ -> string.
    # * *Returns* :
    #   -
    # * *Raises* :
    #
    def depends_on?(package_name)
      self.depends.split(', ').map{|n| n.split[0]}.include?(package_name) if self.depends
    end

    # package.add_dependency('vlan') or with version package.add_dependency('vlan', "23.4")
    #
    # * *Args*    :
    #   - +package_name+ -> string.
    #   - +versions+ -> dependency versions in debian format.
    # * *Returns* :
    #   -
    # * *Raises* :
    #
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

    # package.add_dependency('vlan') or with version package.add_dependency('vlan', "23.4")
    #
    # * *Args*    :
    #   - +Dependency name+ -> The dependency name you want to be removed
    # * *Returns* :
    #   -
    # * *Raises* :
    #
    def remove_dependency(package_name)
      self.depends = self.depends.split(', ').delete_if{|a| a.split[0] == package_name}.join(', ')
      self.save
    end

    # FIXME: maybe we should rename it: dependencies
    #
    # * *Args*    :
    # * *Returns* :
    #   - Return an array of package names it depends on
    # * *Raises* :
    #
    def depends_on
      self.depends.split(', ').inject([]) do |res, name|
        res << self.class.where(:name => name.split(/ /)[0]).first
        res
      end
    end

    # generates the homepage from option homepage_proc
    #
    # * *Args*    :
    # * *Returns* :
    #   - Return the homepage url.
    # * *Raises* :
    #
    def homepage
      package_options[:homepage_proc].call(self)
    end

    #
    # * *Args*    :
    # * *Returns* :
    #   - Return the maintainer's name
    # * *Raises* :
    #
    def maintainer
       "#{package_options[:maintainer]}"
    end

    #
    # * *Args*    :
    # * *Returns* :
    #   - Return the package section
    # * *Raises* :
    #
    def section
      package_options[:section]
    end

    #
    # * *Args*    :
    # * *Returns* :
    #   - return the email of the maintainer
    # * *Raises* :
    #
    def email
      package_options[:email]
    end

    #
    # * *Args*    :
    # * *Returns* :
    #   - Return the complete filename with .deb extension
    # * *Raises* :
    #
    def deb_file_name
      "#{self.name}_#{self.version}_all.deb"
    end

    # * *Args*    :
    #   - +package_name+ -> string.
    # * *Returns* :
    #   -
    # * *Raises* :
    #
    def add_script (type, script)
      new_script = self.scripts.new
      new_script.stype = type.to_s

      if script.is_a? File
        logger.debug ("Adding a script, the object is a File")
        new_script.name = File.basename(script.path)
        new_script.attach = script

      elsif File.exist? script # it's path
        logger.debug ("Adding a script, the object is a path")
        new_script.name = File.basename(script)
        new_script.attach = File.new(script, 'r')

      elsif script.is_a? String # it's a script body
        logger.debug ("Adding a script, the object is a script content")
        tfile = Tempfile.new(type.to_s)
        File.open(tfile, 'w') { |f| f.print script }
        new_script.name = type.to_s
        new_script.attach = tfile

      else
        raise "Script is not a file, a path or a string"
      end

      new_script.save
    end

  end
end
end
