$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "active_debian_repository/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "active_debian_repository"
  s.version     = ActiveDebianRepository::VERSION
  s.authors     = ["Pietro Donatini", "Mattia Lambertini"]
  s.email       = ["support@virtlab.unibo.it"]
  s.homepage    = ""
  s.summary     = "Utilities for Debian Packages"
  s.description = "Utilities for Debian Packages"
  s.license     = "MIT"

  s.require_paths = ['lib']
  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.2.1"
  s.add_dependency "spawnling"
  s.add_dependency "mini_magick" # ActiveStorage
  
  s.add_development_dependency "sqlite3"
  # s.add_development_dependency "rspec-rails"
  s.add_development_dependency "factory_bot"
end
