# ActiveDebianRepository

ActiveDebianRepository Gem is used in [Cpkg-on-rails](https://github.com/virtlab-unibo/cpkg-on-rails)
to handle Debian repositories.

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
  act_as_apt_source
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




:FIMXE copy db/migration from the gem 

### ActiveDebianRepository::Package

in your project you use this component adding
`act_as_debian_package` in your model (< ActiveRecord::Base).

```ruby
class Package < ActiveRecord::Base
  belongs_to :archive
  act_as_debian_package :section      => 'vlab',
                        :homepage_proc => lambda {|p| "https://www.virtlab.unibo.it/cpkg/courses/#{p.course.id}"},
                        :maintainer   => "Unibo Virtlab",
                        :email        => "support@virtlab.unibo.it",
                        :install_dir  => '/usr/share/unibo',
                        :repo_dir     => '/var/www/repo/dists/packages',
                        :core_dep     => 'vlab-core',
                        :hide_depcore => true
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
 
### ActiveDebianRepository::DebPckFile

Given a `ActiveDebianRepository::Package` it provides a methods to create the debian
`.deb` file (internally it uses `EQUIVS_BUILD_COMMAND = "/usr/bin/equivs-build"`).

```ruby
package = ActiveDebianRepository::Package.first
ActiveDebianRepository::DebPckFile.new(package).create
```

The file is created in `package.repo_dir` dir and 
is named `package.deb_file_name`.

For example, given

```ruby
package = ActiveDebianRepository::Package.new(:name => 'test123', 
                                :version => '12.8', 
                                :repo_dir => '/var/www/repo/dists/packages')
```

the file is created as `/var/www/repo/dists/packages/test123_12.8.deb`

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

