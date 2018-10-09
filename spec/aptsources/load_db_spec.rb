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
    a = FactoryBot.create(:aptsource)
    a.update_db(@test_file)
    expect(a.packages.where(name: '0ad').first.name).to eq('0ad')
    expect(a.packages.where(name: 'adabrowse').first.version).to eq('4.0.3-5')
  end

  it "should update database" do
    a = FactoryBot.create(:aptsource)
    a.update_db(@test_file)
    a.update_db(@test_file_different)
    expect(a.packages.where(:name => '389-console')).to be_empty
    expect(a.packages.where(:name => '0ad').first.version).to eq('0~r11853-2')
  end

  it "should update database even with null version" do
    a = FactoryBot.create(:aptsource)
    a.update_db(@test_file)
    a.packages.first.update_attribute(:version, nil)
    a.update_db(@test_file_different)
    expect(a.packages.where(:name => '389-console')).to be_empty
    expect(a.packages.where(:name => '0ad').first.version).to eq('0~r11853-2')
  end
end


