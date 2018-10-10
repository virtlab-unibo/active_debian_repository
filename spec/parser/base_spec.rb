require 'spec_helper'

describe "Parser" do

  before(:all) do
    @test_file = File.dirname(__FILE__) + "/../../testdata/Packages"
  end

  it "should read Package file and get the 2vcard packageas first" do
    ActiveDebianRepository::Parser.new(@test_file).each do |package|
      expect(package['package']).to eq "0ad"
      expect(package['version']).to eq "0~r11863-2"
      expect(package['filename']).to eq %|pool/main/0/0ad/0ad_0~r11863-2_i386.deb|
      break
    end
  end

  it "db_attributes should give correct attributes" do
    ActiveDebianRepository::Parser.new(@test_file).each do |package|
      da = ActiveDebianRepository::Parser.db_attributes(package)
      expect(da[:name]).to eq "0ad"
      expect(da[:short_description]).to eq "Real-time strategy game of ancient warfare"
      break
    end
  end
end

