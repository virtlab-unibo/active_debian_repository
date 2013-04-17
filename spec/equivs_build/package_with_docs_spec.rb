require 'spec_helper'
require 'tmpdir'

describe "Build packages with documents" do

  REPO = "/tmp"

  before(:all) do
    @package = FactoryGirl.build(:package)
    # delete the package if already exists 
    @expected_file_name = File.join(REPO, @package.deb_file_name)
    File.delete(@expected_file_name) if File.exists? @expected_file_name
    
    # create a dummy file on disk
    file_tmp = '/tmp/pippo_Pluto_paperino'
    @random_string = ('a'..'z').to_a.shuffle[0,20].join
    File.delete(file_tmp) if File.exists? file_tmp
    File.open(file_tmp, 'w') {|file| file.print @random_string}

    # add the file to the package
    document = FactoryGirl.build(:document)
    document.file_name = "pippo_Pluto_paperino"
    document.path = "/tmp"
    document.install_path = "/usr/share/test"
    @package.add_file(document)
  end

  it "should successfully create a package with a document" do
    ActiveDebianRepository::Equivs.new(@package, REPO).create.should be_true
  end
    
  it "the package previuosly created should contain an attach file with the correct content" do
    Dir.mktmpdir do |tmp_dir|
      res = `dpkg -x #{@expected_file_name} #{tmp_dir}`
      $?.success?.should be_true
      doc = @package.files[0]
      attach = File.join(tmp_dir, doc.install_path, doc.file_name)
      p attach
      File.exists?(attach).should be_true
      File.open(attach, 'r'){|file| file.readline.should == @random_string}
    end
  end

end


