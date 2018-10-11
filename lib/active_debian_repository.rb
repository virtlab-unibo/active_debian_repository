require "active_debian_repository/version"
require 'rails/all'

require 'spawnling'

module ActiveDebianRepository
  class Railtie < ::Rails::Railtie
  end
end

require "active_debian_repository/version"
require "active_debian_repository/parser"
require "active_debian_repository/aptsource"
require "active_debian_repository/package"
require "active_debian_repository/equivs"
require "active_debian_repository/repository"
require "active_debian_repository/changelog"

::ActiveRecord::Base.extend ActiveDebianRepository::Package
::ActiveRecord::Base.extend ActiveDebianRepository::AptSource
::ActiveRecord::Base.extend ActiveDebianRepository::Changelog

I18n.load_path += Dir.glob( File.dirname(__FILE__) + "lib/locales/*.{rb,yml}" ) 

# https://www.debian.org/doc/manuals/maint-guide/dreq.en.html
