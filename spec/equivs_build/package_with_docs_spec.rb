require 'spec_helper'
require 'tmpdir'

describe "Build packages with files" do

  REPO = "/tmp"

  before(:all) do
    @package = FactoryGirl.create(:package)
    @equivs = ActiveDebianRepository::Equivs.new(@package, REPO)
    # delete the package if already exists 
    @expected_file_name = File.join(REPO, @equivs.package_filename)
    File.delete(@expected_file_name) if File.exists? @expected_file_name
    
    # create a dummy file on disk
    file_tmp = '/tmp/pippo_Pluto_paperino'
    @random_string = ('a'..'z').to_a.shuffle[0,20].join
    File.delete(file_tmp) if File.exists? file_tmp
    File.open(file_tmp, 'w') {|file| file.print @random_string}

    # add the file to the package
    item = @package.items.new
    item.name = 'pippo_Pluto_paperino'
    item.install_path = "/usr/share/test"
    File.open(file_tmp, 'rb') do |f| 
      item.attach = f 
      item.save
    end
  end

  it "should successfully create a package with a file" do
    @equivs.create.should be_true
  end
    
  it "should contain an attach file with the correct content" do
    Dir.mktmpdir do |tmp_dir|
      res = `dpkg -x #{@expected_file_name} #{tmp_dir}`
      $?.success?.should be_true
      file = @package.items[0]
      attach = File.join(tmp_dir, file.install_path, file.name)
      p "FILE ATTACCHED: #{attach}"
      File.exists?(attach).should be_true
      File.open(attach, 'r'){|file| file.readline.should == @random_string}
    end
  end

end


