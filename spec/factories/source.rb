# deb http://mi.mirror.garr.it/mirrors/debian/ stable main contrib non-free
FactoryGirl.define do
  factory :source do
    uri          'http://mi.mirror.garr.it/mirrors/debian'
    distribution 'stable'
    component    'main'
    arch         'binary-amd64'  # 'binary-amd64', 'binary-i386', 'source'
  end
end

def FactoryGirl.add_packages_from_file(source, file)
  ActiveDebianRepository::Parser.new(file).each do |p|
    source.packages.create!(ActiveDebianRepository::Parser.db_attributes(p))
  end
end
