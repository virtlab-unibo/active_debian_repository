require 'spec_helper'

# INSERT INTO sources VALUES (0, 'http://mi.mirror.garr.it/mirrors/debian/', 'stable', "main", 'binary-amd64');
# t.string  "uri",          :limit => 250
# t.string  "distribution", :limit => 50
# t.string  "component",    :limit => 50
# t.string  "arch",         :limit => 20

describe "Factory sources" do
  
  it "factory should create valid source" do
    a = FactoryGirl.build(:source)
    a.should be_valid
  end

end


