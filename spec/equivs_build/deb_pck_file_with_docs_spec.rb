require 'spec_helper'
require 'tmpdir'

describe "DebPckFile with documents" do

  before(:all) do
    @package = FactoryGirl.create(:package)
    
    @attach_file = '/tmp/pippo_Pluto_paperino'
    @random_string = ('a'..'z').to_a.shuffle[0,20].join

    File.delete(@attach_file) if File.exists? @attach_file
    File.open(@attach_file, 'w') {|file| file.print @random_string}

    @expected_file_name = File.join(@package.repo_dir, @package.deb_file_name)
    File.delete(@expected_file_name) if File.exists? @expected_file_name

    @document = @package.documents.new
    @document.name = 'test oh mio test'
    File.open(@attach_file, 'rb') do |f|
      @document.attach = f
      @document.save
    end

    ActiveDebianRepository::DebPckFile.new(@package).create.should be_true
  end
    
  it "should contain attach file witch correct content" do
    Dir.mktmpdir do |tmp_dir|
      res = `dpkg -x #{@expected_file_name} #{tmp_dir}`
      $?.success?.should be_true
      attach = File.join(tmp_dir, @package.install_dir, @package.name, 'pippo_Pluto_paperino')
      File.exists?(attach).should be_true
      File.open(attach, 'r'){|file| file.readline.should == @random_string}
    end
  end

end


