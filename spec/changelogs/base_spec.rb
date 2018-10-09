require 'spec_helper'

describe "Changelog base" do

  before(:all) do
    @chlog = Changelog.new
  end

  it "urgency value should be nil by default" do
    expect(@chlog.urgency).to be_nil
  end

  it "description should be nil by default" do
    expect(@chlog.description).to be_nil
  end

  it "version value should be nil by default" do
    expect(@chlog.version).to be_nil
  end

  it "date value should be nil by default" do
    expect(@chlog.date).to be_nil
  end

  it "distributions value should be nil by default" do
    expect(@chlog.distributions).to be_nil
  end

  it "package should be nil" do
    expect(@chlog.package).to be_nil
  end

  it "changelog should be saved correctly into the database" do
    @chlog.package = FactoryBot.create(:package)
    @chlog.save
    expect(@chlog.pacage).to_be
  end

  it "changelog.to_s should return a valid debian changelog string" do
    expect(@chlog.to_s).to_be eq(%Q[test-name (2.0-1) precise; urgency=high

  description line
   minor fix

 -- Unibo Virtlab <info@virtlab.unibo.it>  Wed, 24 May 2013 16:34:23 +0200]
   )
  end

end
