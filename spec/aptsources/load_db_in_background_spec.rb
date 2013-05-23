# WE NEED REAL CONNECTION (not memory) IN ORDER
# TO USE https://github.com/tra/spawnling
require 'spec_helper'

describe "Aptsource" do

  before(:all) do
    @test_file = File.dirname(__FILE__) + "/../../testdata/Packages"
    # 0ad -> 0~r11853-2
    # 389-console deleted
    # adacontrol -> 1.14r4-3
    # circuslinux added
    @test_file_different = File.dirname(__FILE__) + "/../../testdata/Packages_different"

    ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database  => "/tmp/pippo123")
    load(File.dirname(__FILE__) + "/../schema.rb") 
  end
  
  it "should insert data in clean database in background" do
    # we need file connection sqlite
    a = FactoryGirl.create(:aptsource)
    a.update_db_in_background(@test_file)
    while a.update_db_running? do 
      sleep 1
    end
    a.packages.where(:name => '0ad').first.name.should == '0ad'
  end
end


