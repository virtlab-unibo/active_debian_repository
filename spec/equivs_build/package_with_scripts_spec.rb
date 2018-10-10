require 'spec_helper'
require 'tmpdir'

describe "Build packages with scripts" do

  # delete previous package and create new
  before(:all) do
    @package = FactoryBot.create(:package)
    @script = %q[#!/bin/bash -e
     echo "Hello I'M a Test!"
     exit 0]
    @preinst_file = "/tmp/preprova"
    @postinst_file = "/tmp/postprova"
    @equivs = ActiveDebianRepository::Equivs.new(@package, REPO_DIR)
    # in test its /tmp/repo
    @expected_file_name = File.join(REPO_DIR, @equivs.package_filename)
  end

  before(:each) do
    File.delete(@expected_file_name) if File.exists? @expected_file_name
    File.open(@postinst_file, "w") { |f| f.write(@script) }
    File.open(@preinst_file, "w") { |f| f.write(@script) }
  end

  it "should create a deb with a postinst script " do
    @package.add_script(:postinst, @postinst_file)
    expect(File.exists?(@equivs.create)).to be true

    Dir.mktmpdir do |tmp_dir|
      res = `dpkg -e #{@expected_file_name} #{tmp_dir}`
      expect($?.success?).to be true

      postinst = File.join(tmp_dir, 'postinst')
      expect(File.exists?(postinst)).to be true
    end
  end

  it "should create a deb with a preinst script " do
    @package.add_script(:preinst, @preinst_file)
    expect(File.exists?(ActiveDebianRepository::Equivs.new(@package, REPO_DIR).create)).to be true

    Dir.mktmpdir do |tmp_dir|
      res = `dpkg -e #{@expected_file_name} #{tmp_dir}`
      expect($?.success?).to be true

      preinst = File.join(tmp_dir, 'preinst')
      expect(File.exists?(preinst)).to be true
    end
  end

  it "should create a deb with a preinst and postinst script " do
    @package.add_script(:preinst, @preinst_file)
    @package.add_script(:postinst, @postinst_file)
    expect(File.exists?(ActiveDebianRepository::Equivs.new(@package, REPO_DIR).create)).to be true

    Dir.mktmpdir do |tmp_dir|
      res = `dpkg -e #{@expected_file_name} #{tmp_dir}`
      expect($?.success?).to be true

      postinst = File.join(tmp_dir, 'postinst')
      preinst = File.join(tmp_dir, 'preinst')
      expect(File.exists?(postinst)).to be true
      expect(File.exists?(preinst)).to be true
    end
  end

end
