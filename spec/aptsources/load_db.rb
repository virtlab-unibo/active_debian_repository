require 'spec_helper'

describe "Aptsource" do

  before(:all) do
    @test_file = File.dirname(__FILE__) + "/../../testdata/Packages"
    # 0ad -> 0~r11853-2
    # 389-console deleted
    # adacontrol -> 1.14r4-3
    # circuslinux added
    @test_file_different = File.dirname(__FILE__) + "/../../testdata/Packages_different"
  end
  
  it "should insert data in clean database" do
    a = FactoryGirl.create(:aptsource)
    a.update_db(@test_file)
    a.packages.where(:name => '0ad').first.name.should == '0ad'
    a.packages.where(:name => 'adabrowse').first.version.should == '4.0.3-5'
  end

  it "should update database" do
    a = FactoryGirl.create(:aptsource)
    a.update_db(@test_file)
    puts "-----------------------------------------------------"
    a.update_db(@test_file_different)
    a.packages.where(:name => '389-console').all.should be_empty
    a.packages.where(:name => '0ad').first.version.should == '0~r11853-2'
  end

  it "should update database downloading from network" do
    a = FactoryGirl.create(:aptsource, {uri: 'http://mozilla.debian.net',
                                      distribution: 'squeeze-backports', 
                                      component: 'iceweasel-release', 
                                      arch: 'binary-i386'})
    a.update_db_from_net
    a.packages.where(:name => 'xulrunner-dev').all.should_not be_empty
    p a.packages.map(&:name)
  end

end


