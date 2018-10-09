require 'spec_helper'

describe "Equivs control string method" do

  before(:each) do
    @package = FactoryBot.create(:package)
  end

  # in spec_helper abbiamo definito i default di repo.... 
  # see spec/factories/package.rb
  it "should create correct control string" do
    expect(ActiveDebianRepository::Equivs.new(@package, REPO_DIR).to_s).to eq("Section: Misc\nPriority: optional\nHomepage: http://example.it/cpkg/test\nStandards-Version: 3.9.2\nPackage: test-name\nVersion: 1.2.3\nMaintainer: Unibo Virtlab <info@virtlab.unibo.it>\nArchitecture: all\nDescription: I'm a short description\n I'm a\n .\n description\n .\n on three lines\n")
  end

  # in spec_helper abbiamo definito i default di repo.... 
  it "should create correct control with empty lines in long_description" do
    @package.long_description = "description\n\n with spaces\n \n and notspaces"
    expect(ActiveDebianRepository::Equivs.new(@package, REPO_DIR).to_s).to eq("Section: Misc\nPriority: optional\nHomepage: http://example.it/cpkg/test\nStandards-Version: 3.9.2\nPackage: test-name\nVersion: 1.2.3\nMaintainer: Unibo Virtlab <info@virtlab.unibo.it>\nArchitecture: all\nDescription: I'm a short description\n description\n .\n  with spaces\n .\n  and notspaces\n")
  end

  it "should create correct control string with postinst and preinst script into it" do
    @package.add_script(:postinst, %q[#!/bin/bash -e
                            echo "Hello I'M a Test!"
                            exit 0])
    equivs = ActiveDebianRepository::Equivs.new(@package, REPO_DIR)
    expect(equivs.to_s).to match(/^.*Postinst: .*postinst.*$/)

    tmp_file = '/tmp/pippopluto2'
    File.open(tmp_file, "w"){|f| f.puts "test"}
    @package.add_script(:preinst, tmp_file)
    equivs = ActiveDebianRepository::Equivs.new(@package, REPO_DIR)
    expect(equivs.to_s).to match(/^.*Postinst: .*postinst.*\nPreinst: .*pippopluto2.*$/) 
  end

end
