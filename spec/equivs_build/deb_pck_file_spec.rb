require 'spec_helper'
require 'tmpdir'

describe "DebPckFile" do

  # delete previous package and create new
  before(:all) do
    @package = FactoryGirl.build(:package)
    p @package
    @expected_file_name = File.join(@package.repo_dir, @package.deb_file_name)
    p @expected_file_name
    File.delete(@expected_file_name) if File.exists? @expected_file_name
    ActiveDebianRepository::DebPckFile.new(@package).create.should be_true
  end

  it "should create dpkg file with correct name and in correct dir" do
    File.exists?(@expected_file_name)
  end

  it "should be extractable with dpkg and contain in /usr/share/doc/... README.Debian" do
    Dir.mktmpdir do |tmp_dir|
      res = `dpkg -x #{@expected_file_name} #{tmp_dir}`
      $?.success?.should be_true
      debian_readme = File.join(tmp_dir, '/usr/share/doc/', @package.name, 'README.Debian')
      p debian_readme
      File.exists?(debian_readme).should be_true
    end
  end

  it "should fail to obtain the lock" do
    # delete previously created package
    File.delete(@expected_file_name) if File.exists? @expected_file_name
    # create lock directory to make the create package fail
    Dir.mkdir("/var/lock/updaterepo.lock") 
    ActiveDebianRepository::DebPckFile.new(@package).create.should be_false
    Dir.rmdir("/var/lock/updaterepo.lock") 
  end 

end

