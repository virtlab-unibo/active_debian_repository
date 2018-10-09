require 'spec_helper'
require 'tmpdir'

describe "Build packages with changelogs" do

  before(:all) do
    @package = FactoryBot.create(:package)
    @equivs = ActiveDebianRepository::Equivs.new(@package, REPO_DIR)
    
    # add a changelog to the package
    chlog = @package.changelogs.new
    chlog.version = "0.5-3"
    chlog.date = ActiveDebianRepository::Changelog.date_line
    chlog.urgency = "medium"
    chlog.distributions = "precise"
    chlog.description = "I'm a test!"
    chlog.save
    @package.version = chlog.version

    # delete the package if already exists 
    @expected_file_name = File.join(REPO_DIR, @equivs.package_filename)
    File.delete(@expected_file_name) if File.exists? @expected_file_name
  end

  it "should successfully create a package" do
    expect(File.exists?(@equivs.create)).to be true
  end
    
  it "should contain a single changelog with the correct content" do
    Dir.mktmpdir do |tmp_dir|
      res = `dpkg -x #{@expected_file_name} #{tmp_dir}`
      expect($?.success?).to be true

      chlog_gz = File.join(tmp_dir, "usr/share/doc/", @package.name, "changelog.Debian.gz")
      expect(File.exists?(chlog_gz)).to be true
      # FIXME: open the changelog.gz file and check contents
      #File.open(attach, 'r'){|file| file.readline.should == @random_string}
    end
  end

  it "should successfully create a package with two changelogs" do
    
    # add a changelog to the package
    chlog = @package.changelogs.new
    chlog.version = "0.5-4"
    chlog.date = ActiveDebianRepository::Changelog.date_line
    chlog.urgency = "medium"
    chlog.distributions = "precise"
    chlog.description = "I'm a second test!"
    chlog.save
    @package.version = chlog.version

    # delete the package if already exists 
    @expected_file_name = File.join(REPO_DIR, @equivs.package_filename)
    File.delete(@expected_file_name) if File.exists? @expected_file_name

    expect(File.exists?(@equivs.create)).to be true
  end

end


