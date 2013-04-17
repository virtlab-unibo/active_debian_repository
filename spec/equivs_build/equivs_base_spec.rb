require 'spec_helper'
require 'tmpdir'

describe "Equivs" do

  REPO = "/tmp"

  # delete previous package and create new
  before(:all) do
    @package = FactoryGirl.build(:package)
    @expected_file_name = File.join(REPO, @package.deb_file_name)
    p @expected_file_name
    p @package
    File.delete(@expected_file_name) if File.exists? @expected_file_name
    ActiveDebianRepository::Equivs.new(@package, REPO).create.should be_true
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

end

