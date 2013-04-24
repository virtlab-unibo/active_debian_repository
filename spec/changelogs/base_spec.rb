require 'spec_helper'

describe "Changelog base " do

  before(:all) do
    @chlog = Changelog.new #FactoryGirl.create(:changelog)
  end

  it " urgency value should be nil by default" do
      @chlog.urgency.should be_nil
  end

  it " description should be nil by default" do
      @chlog.description.should be_nil
  end

  it " version value should be nil by default" do
      @chlog.version.should be_nil
  end

  it " date value should be nil by default" do
      @chlog.date.should be_nil
  end

  it " distributions value should be nil by default" do
      @chlog.distributions.should be_nil
  end

  it " urgency value should be settable to high" do
    @chlog.urgency = "high"
    @chlog.urgency.should == "high"
  end

  it "date value should be settable 'Wed, 24 04 2013 16:34:23 +0200'" do
    @chlog.date = "Wed, 24 04 2013 16:34:23 +0200"
    @chlog.date.should == "Wed, 24 04 2013 16:34:23 +0200"
  end

  it " distributions should be settable to 'precise'" do
    @chlog.distributions = "precise"
    @chlog.distributions.should == "precise"
  end

  it " version value should be settable to 2.0-1" do
    @chlog.version = "2.0-1"
    @chlog.version.should == "2.0-1"
  end

  it " description value should be settable to 'description line\n minor fix'" do
    @chlog.description = "description line\n minor fix"
    @chlog.description.should == "description line\n minor fix"
  end

  it " package should be nil" do
    @chlog.package.should be_nil
  end

  it "changelog should be saved correctly into the database" do
    @chlog.package = FactoryGirl.create(:package)
    @chlog.save
  end

  it "changelog.to_s should return a valid debian changelog string" do
    @chlog.to_s.should == %Q[test-name (2.0-1) precise; urgency=high

  description line
   minor fix

 -- Unibo Virtlab <info@virtlab.unibo.it>  Wed, 24 04 2013 16:34:23 +0200]
  end

end
