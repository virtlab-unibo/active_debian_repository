# -*- encoding: utf-8 -*-
require File.expand_path('../lib/active_debian_repository/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Pietro Donatini", "Mattia Lambertini"]
  gem.email         = ["support@virtlab.unibo.it"]
  gem.description   = %q{Utilities for Debian Packages}
  gem.summary       = %q{Utilities for Debian Packages}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "active_debian_repository"
  gem.require_paths = ["lib"]
  gem.version       = ActiveDebianRepository::VERSION

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'

  gem.add_dependency 'spawnling'
end
