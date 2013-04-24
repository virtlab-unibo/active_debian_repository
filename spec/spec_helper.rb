require 'rubygems'
require 'logger'
require 'active_debian_repository'
require 'factory_girl'
require 'paperclip'

ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/rspec.log")
ActiveRecord::Base.establish_connection(YAML::load(IO.read(File.dirname(__FILE__) + "/database.yml"))['sqlite3'])
load(File.dirname(__FILE__) + "/schema.rb") 

class Aptsource < ActiveRecord::Base
  has_many :packages
  acts_as_apt_source
end

class Package < ActiveRecord::Base
  belongs_to :aptsource
  has_many   :items
  has_many   :scripts
  has_many   :changelogs

  acts_as_debian_package :install_dir => '/usr/share/unibo',
                        :homepage_proc => lambda {|p| "http://example.it/cpkg/#{p.my_meth}"},
                        :repo_dir    => '/var/www/repo/dists/packages',
                        :maintainer  => "Unibo Virtlab",
                        :email       => "info@virtlab.unibo.it"
  def my_meth
    "my_meth_result" 
  end
end

#TODO: We need to consider Acts_as_debian_item 
class Item < ActiveRecord::Base
  include Paperclip::Glue
  belongs_to :package

  has_attached_file :attach,
                    :path => "#{File.dirname(__FILE__)}:url"

  def to_s
#    self.description.blank? ? self.attach_file_name : self.description
    self.attach_file_name
  end
end

class Script < ActiveRecord::Base
  include Paperclip::Glue
  belongs_to :package

  validates_format_of :stype, :with => /^(preinst|postinst|prerm|postrm)$/, :message => :script_type_unknown

  has_attached_file :attach,
                    :path => "#{File.dirname(__FILE__)}:url"

  def to_s
    self.attach_file_name
  end
end

class Changelog < ActiveRecord::Base
  belongs_to :package

  acts_as_debian_changelog

end

FactoryGirl.find_definitions
