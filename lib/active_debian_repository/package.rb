require 'tmpdir'
require 'tempfile'

module ActiveDebianRepository
module Package

  def acts_as_debian_package(options={})

    # Declare a class-level attribute whose value is inheritable by subclasses.
    # Subclasses can change their own value and it will not impact parent class.
    class_attribute :package_options

    # name must consist only of lower case letters (a-z), digits (0-9), plus (+) and minus (-) signs, and periods (.).
    # They must be at least two characters long and must start with an alphanumeric character.
    validates_format_of :name, :with => /^[a-z0-9][a-z0-9+.-]+$/, :message => :package_name_format

    self.package_options = {
      :section        => 'Misc',
      :maintainer     => 'Maintainer',
      :email          => 'debutils@example.com',
      :architecture   => 'all',
      :priority       => 'optional',
      :standards_version => '3.9.2'
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

    # Return the default value if the method name is a 
    # known package property. Raise otherwise.
    # TODO: do we have to handle nil cases?
    #
    # * *Args*    :
    # * *Returns* :
    #   - Return the property value if defined.
    # * *Raises* :
    #   - NoMethodError 
    #
    def method_missing (method_name, *args, &block)
      if not package_options.has_key? method_name
        super
      end
      self.package_options[method_name]
    end

    # 
    # * *Args*    :
    # - type: the symbol representing the type of the script
    # * *Returns* :
    #   - Return the path of the script identimied by the type
    #   - nil if no such a script exist.
    # * *Raises* :
    #
    def get_script type
      result = nil
      self.scripts.each do |script|
        if script.stype.to_sym == type.to_sym
          result = script.attach.path
        end
      end
      result
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
