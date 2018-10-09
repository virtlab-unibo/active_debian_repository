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
  end
  
  it "should insert data in clean database in background" do
    # we need file connection sqlite
    a = FactoryBot.create(:aptsource)
    a.update_db_in_background(@test_file)
    while a.update_db_running? do 
      puts "sleeping 1"
      sleep 1
    end
    expect(a.packages.where(name: '0ad')).not_to be_empty
    expect(a.packages.where(name: '0ad').first.name).to eq('0ad')
  end
end


