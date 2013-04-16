require 'active_record'
require "active_debian_repository/version"

module ActiveDebianRepository
end

require "active_debian_repository/version"
require "active_debian_repository/parser"
require "active_debian_repository/aptsource"
require "active_debian_repository/package"
require "active_debian_repository/deb_pck_file"
require "active_debian_repository/repository"

::ActiveRecord::Base.extend ActiveDebianRepository::Package
::ActiveRecord::Base.extend ActiveDebianRepository::AptSource

I18n.load_path += Dir.glob( File.dirname(__FILE__) + "lib/locales/*.{rb,yml}" ) 
