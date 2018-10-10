require 'rubygems'
require 'logger'
require 'active_debian_repository'
require 'factory_bot'
require 'paperclip'

REPO_DIR = "/tmp/repo"

ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/rspec.log")
ActiveRecord::Base.logger.level = Logger::DEBUG

begin
  Dir.mkdir(REPO_DIR)
rescue
  ActiveRecord::Base.logger.debug "REPO_DIR already exist"
end

ActiveRecord::Base.establish_connection(YAML::load(IO.read(File.dirname(__FILE__) + "/database.yml"))['sqlite3'])
load(File.dirname(__FILE__) + "/schema.rb") 

Paperclip::Attachment.default_options[:validate_media_type] = false

class Aptsource < ActiveRecord::Base
  has_many :packages
  acts_as_apt_source
end

class Package < ActiveRecord::Base
  belongs_to :aptsource
  has_many   :documents
  has_many   :scripts
  has_many   :changelogs

  acts_as_debian_package maintainer: "Unibo Virtlab",
                         email:      "info@virtlab.unibo.it"
                         #insert your key id if you want to sign packages
                         # :gpg_key     => "09A0DEDE",
end

#TODO: We need to consider Acts_as_debian_document
class Document < ActiveRecord::Base
  include Paperclip::Glue
  belongs_to :package

  has_attached_file :attach, path: "#{File.dirname(__FILE__)}:url"
  do_not_validate_attachment_file_type :attach

  def to_s
#    self.description.blank? ? self.attach_file_name : self.description
    self.attach_file_name
  end
end

class Script < ActiveRecord::Base
  include Paperclip::Glue
  belongs_to :package

  validates_format_of :stype, :with => /\A(preinst|postinst|prerm|postrm)\z/, :message => :script_type_unknown

  has_attached_file :attach, path: "#{File.dirname(__FILE__)}:url"
  do_not_validate_attachment_file_type :attach

  def to_s
    self.attach_file_name
  end
end

class Changelog < ActiveRecord::Base
  belongs_to :package

  acts_as_debian_changelog
end

FactoryBot.find_definitions
