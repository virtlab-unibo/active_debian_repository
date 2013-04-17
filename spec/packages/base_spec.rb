require 'spec_helper'

describe "Package base" do

  before(:all) do
    @test_file = File.dirname(__FILE__) + "/../../testdata/Packages"
    a = FactoryGirl.create(:aptsource)
    a.update_db(@test_file)
  end

  it "depends_on should return empty array of if no dependecies" do
    package = FactoryGirl.build(:package)
    package.depends_on.should be_empty
  end

  it "depends_on should return array of correct number of packages" do
    package = FactoryGirl.build(:package)
    package.depends = "2vcard (<< 0.5-3), 3dchess (<< 0.8.1-17)"
    package.depends_on.size.should == 2
  end

  it "depends_on should return array of packages with correct names" do
    package = FactoryGirl.build(:package)
    package.depends = "2vcard (<< 0.5-3), 3dchess (<< 0.8.1-17)"
    package.depends_on.map(&:name).sort.should == ['2vcard', '3dchess']
  end

  it "depends_on? should return false on nil depend" do
    package = FactoryGirl.build(:package)
    package.depends = nil
    package.depends_on?('2vcard').should be_false
  end

  it "depends_on? should return true on depend package and false otherwise" do
    package = FactoryGirl.build(:package)
    package.depends = "2vcard (<< 1:3.1.0-3), 3dchess (<< 3.0-1~)"
    package.depends_on?('2vcard').should be_true
    package.depends_on?('2vcar').should be_false
  end

  it "depends_on? should return true on depend package and false otherwise" do
    package = FactoryGirl.build(:package)
    package.depends = "2vcard (<< 1:3.1.0-3), 3dchess (<< 3.0-1~)"
    package.depends_on?('2vcard').should be_true
    package.depends_on?('2vcar').should be_false
  end

  it "add_script should had a item into the scripts hashes with key :script_type (Ex. postinst)" do
    package = FactoryGirl.build(:package)
    content = %q{#!/bin/sh -e
# test script

echo "test script"

exit 0}
    package.add_script :postinst, content
    package.scripts.size.should == 1
    package.scripts[:postinst].should_not be_nil
  end

end


