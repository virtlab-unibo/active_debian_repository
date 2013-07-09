# ActiveDebianRepository

ActiveDebianRepository Gem is used in [Cpkg-on-rails](https://github.com/virtlab-unibo/cpkg-on-rails)
to handle Debian repositories. Its main purpose is to create debian metapackages
(packages with documents and dependencies but not installable software) and
place it in the right folder under a debian repository.

## Requirements

* ruby 2.0.0p195
* dpkg installed on the system
* debhelper installed on the system

## Installation

Add this line to your application's Gemfile:

    gem 'active_debian_repository'

And then execute:

    $ bundle

## Migration

    rails generate active_debian_repository:migration
    rake db:migrate


## Components

ActiveDebianRepository has the following components:

### ActiveDebianRepository::AptSource

It handles the debian source (Repository, as in 
/etc/apt/sources.list), for example

```ruby
class AptSource < ActiveRecord::Base
  has_many :packages
  acts_as_apt_source
end
```

and then, in order to register a Repository that corresponds 
to the line `deb http://mi.mirror.garr.it/mirrors/debian/ stable main`
in `/etc/apt/sources.list`, just do

```ruby
source = AptSource.new(:uri => 'http://mi.mirror.garr.it/mirrors/debian',
                     :distribution => 'stable',
                     :component => 'main',
                     :arch => 'binary-amd64')
```

where `arch` can be one of `['binary-amd64', 'binary-i386', 'source']`.

Each Source has_many Packages (from ActiveDebianRepository::Package). The database
can be updated with each package in the archive. With the method
self.db_attrbutes you get the correct attributes for database.

```ruby
source = AptSource.new(...)
source.update_db_from_net
```

all `archive.packages` are inserted in database with their
metadata (name, description, version...). The information
is taken from 
`source.url`




### ActiveDebianRepository::Package

in your project you use this component adding
`acts_as_debian_package` in your model (< ActiveRecord::Base).

```ruby
class Package < ActiveRecord::Base
  belongs_to :archive
  acts_as_debian_package :section      => 'vlab',
                        :homepage => "https://www.virtlab.unibo.it/cpkg/",
                        :maintainer   => "Unibo Virtlab",
                        :email        => "support@virtlab.unibo.it",
end
```

### ActiveDebianRepository::Parser

```ruby
parser = ActiveDebianRepository::Parser.new('/home/tmp/Packages')
parser.each do |package|
  p package
end
```

Takes a file name with the archive index and provides iteration (with each)
for every package in the filename
 
### ActiveDebianRepository::Equivs

Given a `ActiveDebianRepository::Package` it provides a methods to create the debian
`.deb` file (internally it uses dpkg-buildpackage.

```ruby
package = ActiveDebianRepository::Package.first
equivs = ActiveDebianRepository::Equivs.new(package, dest_dir)
equivs.create
```

The file is created in `dest_dir` dir and 
is named `equivs.package_filename`.

For example, given

```ruby
dest_dir = '/var/www/repo/dists/packages'
package = ActiveDebianRepository::Package.new(:name => 'test123', 
                                :version => '12.8') 
                                
```

the file is created as `/var/www/repo/dists/packages/test123_12.8.deb`

### Examples

You can find examples on how to use this gem in the *spec/spec_helper.rb* file.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

