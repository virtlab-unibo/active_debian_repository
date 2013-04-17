require 'spec_helper'

describe "Package homepage generated" do
  it "should generate a correct homepage default" do
    package = FactoryGirl.build(:package)
    # FIXME: check which behaviour we want
    #package.homepage.should be_nil
    #package.generate_homepage
    package.homepage.should == "http://example.it/cpkg/my_meth_result"
  end
end


