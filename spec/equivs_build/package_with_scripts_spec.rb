require 'spec_helper'
require 'tmpdir'

describe "Build packages with scripts" do

  REPO = "/tmp"

  # delete previous package and create new
  before(:all) do
    @package = FactoryGirl.create(:package)
    @script = %q[#!/bin/bash -e
     echo "Hello I'M a Test!"
     exit 0]
    @preinst_file = "/tmp/preprova"
    @postinst_file = "/tmp/postprova"
    @equivs = ActiveDebianRepository::Equivs.new(@package, REPO)
    @expected_file_name = File.join(REPO, @equivs.package_filename)
  end

  before(:each) do
    File.delete(@expected_file_name) if File.exists? @expected_file_name
  end

  it "should create a deb with a postinst script " do
    File.open(@postinst_file, "w") { |f| f.write(@script) }
    @package.add_script(:postinst, @postinst_file)
    @equivs.create.should be_true
    Dir.mktmpdir do |tmp_dir|
      res = `dpkg -e #{@expected_file_name} #{tmp_dir}`
      $?.success?.should be_true
      postinst = File.join(tmp_dir, 'postinst')
      File.exists?(postinst).should be_true
    end
  end

  it "should create a deb with a preinst script " do
    File.open(@preinst_file, "w") { |f| f.write(@script) }
    @package.add_script(:preinst, @preinst_file)
    ActiveDebianRepository::Equivs.new(@package, REPO).create.should be_true
    Dir.mktmpdir do |tmp_dir|
      res = `dpkg -e #{@expected_file_name} #{tmp_dir}`
      $?.success?.should be_true
      preinst = File.join(tmp_dir, 'preinst')
      File.exists?(preinst).should be_true
    end
  end

  it "should create a deb with a preinst and postinst script " do
    File.open(@preinst_file, "w") { |f| f.write(@script) }
    File.open(@postinst_file, "w") { |f| f.write(@script) }
    @package.add_script(:preinst, @preinst_file)
    @package.add_script(:postinst, @postinst_file)
    ActiveDebianRepository::Equivs.new(@package, REPO).create.should be_true
    Dir.mktmpdir do |tmp_dir|
      res = `dpkg -e #{@expected_file_name} #{tmp_dir}`
      $?.success?.should be_true
      postinst = File.join(tmp_dir, 'postinst')
      preinst = File.join(tmp_dir, 'preinst')
      File.exists?(postinst).should be_true
      File.exists?(preinst).should be_true
    end
  end

end
