require 'spec_helper'

# INSERT INTO aptsources VALUES (0, 'http://mi.mirror.garr.it/mirrors/debian/', 'stable', "main", 'binary-amd64');
# t.string  "uri",          :limit => 250
# t.string  "distribution", :limit => 50
# t.string  "component",    :limit => 50
# t.string  "arch",         :limit => 20

describe "Factory aptsources" do
  
  it "factory should create valid aptsource" do
    a = FactoryBot.build(:aptsource)
    expect(a).to be_valid
  end

end


