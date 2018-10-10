require 'spec_helper'

describe "Package homepage generated" do
  it "should generate a correct homepage default" do
    package = FactoryBot.build(:package)
    expect(package.homepage).to eq "http://example.it/cpkg/test"
  end
end


