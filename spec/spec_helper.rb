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
  act_as_apt_source
end

class Package < ActiveRecord::Base
  belongs_to :aptsource
  has_many   :items
  act_as_debian_package :install_dir => '/usr/share/unibo',
                        :homepage_proc => lambda {|p| "http://example.it/cpkg/#{p.my_meth}"},
                        :repo_dir    => '/var/www/repo/dists/packages',
                        :maintainer  => "Unibo Virtlab",
                        :email       => "info@virtlab.unibo.it"
  def my_meth
    "my_meth_result"    
  end
end

# Todo
# Riflettere su act_as_debian_attachment
class Item < ActiveRecord::Base
  include Paperclip::Glue
  belongs_to :package

  # diventa spec/system/documents/attaches/
  has_attached_file :attach,
                    :path => "#{File.dirname(__FILE__)}:url"

  def to_s
#    self.description.blank? ? self.attach_file_name : self.description
    self.attach_file_name
  end
end


FactoryGirl.find_definitions

