require 'spec_helper'

describe "Changelog base" do

  it "changelog should not be valid without a package" do
    @chlog = Changelog.new
    expect(@chlog).not_to be_valid
  end

  it "changelog should be valid with a package" do
    @chlog = Changelog.new
    @chlog.package = FactoryBot.create(:package)
    expect(@chlog).to be_valid
  end

  it "changelog.to_s should return a valid debian changelog string" do
    @chlog = FactoryBot.create(:changelog)
    expect(@chlog.to_s).to eq(%Q[test-name (2018101001-19) precise; urgency=high

  I'am a change description
      * bla bla

 -- Unibo Virtlab <info@virtlab.unibo.it>  Wed, 10 Oct 2018 17:57:37 +0200]
   )
  end

end
