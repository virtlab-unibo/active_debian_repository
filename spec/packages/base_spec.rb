require 'spec_helper'

describe "Package base" do

  before(:all) do
    @test_file = File.dirname(__FILE__) + "/../../testdata/Packages"
    a = FactoryBot.create(:aptsource)
    a.update_db(@test_file)
  end

  it "depends_on should return empty array of if no dependecies" do
    package = FactoryBot.build(:package)
    expect(package.depends_on).to be_empty
  end

  it "depends_on should return array of correct number of packages" do
    package = FactoryBot.build(:package)
    package.depends = "2vcard (<< 0.5-3), 3dchess (<< 0.8.1-17)"
    expect(package.depends_on.size).to eq(2)
  end

  it "depends_on should return array of packages with correct names" do
    package = FactoryBot.build(:package)
    package.depends = "2vcard (<< 0.5-3), 3dchess (<< 0.8.1-17)"
    expect(package.depends_on.map(&:name).sort).to eq ['2vcard', '3dchess']
  end

  it "depends_on? should return false on nil depend" do
    package = FactoryBot.build(:package)
    package.depends = nil
    expect(package.depends_on?('2vcard')).to be false
  end

  it "depends_on? should return true on depend package and false otherwise" do
    package = FactoryBot.build(:package)
    package.depends = "2vcard (<< 1:3.1.0-3), 3dchess (<< 3.0-1~)"
    expect(package.depends_on?('2vcard')).to be
    expect(package.depends_on?('2vcar')).to be false
  end

  it "depends_on? should return true on depend package and false otherwise" do
    package = FactoryBot.build(:package)
    package.depends = "2vcard (<< 1:3.1.0-3), 3dchess (<< 3.0-1~)"
    expect(package.depends_on?('2vcard')).to be
    expect(package.depends_on?('2vcar')).to be false
  end

  it "add_script should had a item into the scripts list with correct info" do
    package = FactoryBot.create(:package)
    content = %q{#!/bin/sh -e
# test script

echo "test script"

exit 0}
    package.add_script :postinst, content
    expect(package.scripts.size).to eq(1)
    expect(package.scripts[0].stype).to eq "postinst"
  end

end


