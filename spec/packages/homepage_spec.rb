require 'spec_helper'

describe "Package homepage generated" do
  it "should generate a correct homepage default" do
    package = FactoryGirl.build(:package)
    package.homepage.should == "http://example.it/cpkg/test"
  end
end


