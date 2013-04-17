require 'spec_helper'

describe "Equivs control string" do

  REPO = "/tmp"

  before(:each) do
    @package = FactoryGirl.build(:package)
  end

  # in spec_helper abbiamo definito i default di repo.... 
  it "should create correct control string" do
    ActiveDebianRepository::Equivs.new(@package, REPO).control_string.should == "Section: Misc\nPriority: optional\nHomepage: http://example.it/cpkg/my_meth_result\nStandards-Version: 3.6.2\n\nPackage: test-name\nVersion: 1.2.3\nMaintainer: Unibo Virtlab <info@virtlab.unibo.it>\nDepends: \nArchitecture: all\n\n\nDescription: I'm a short description\n I'm a\n .\n description\n .\n on three lines\n"
  end

  # in spec_helper abbiamo definito i default di repo.... 
  it "should create correct control with empty lines in long_description" do
    @package.long_description = "description\n\n with spaces\n \n and notspaces"
    ActiveDebianRepository::Equivs.new(@package, REPO).control_string.should == "Section: Misc\nPriority: optional\nHomepage: http://example.it/cpkg/my_meth_result\nStandards-Version: 3.6.2\n\nPackage: test-name\nVersion: 1.2.3\nMaintainer: Unibo Virtlab <info@virtlab.unibo.it>\nDepends: \nArchitecture: all\n\n\nDescription: I'm a short description\n description\n .\n  with spaces\n .\n  and notspaces\n"
  end

  it "should create correct control string with a postinst script into it" do
    pkg = ActiveDebianRepository::Equivs.new(@package, REPO)
    @package.add_script(:postinst, '/tmp/pippopluto')
    pkg.control_string.should ==  "Section: Misc\nPriority: optional\nHomepage: http://example.it/cpkg/my_meth_result\nStandards-Version: 3.6.2\n\nPackage: test-name\nVersion: 1.2.3\nMaintainer: Unibo Virtlab <info@virtlab.unibo.it>\nDepends: \nArchitecture: all\nPostinst: /tmp/pippopluto\n\nDescription: I'm a short description\n I'm a\n .\n description\n .\n on three lines\n"
    @package.add_script(:preinst, '/tmp/pippopluto2')
    pkg.control_string.should ==  "Section: Misc\nPriority: optional\nHomepage: http://example.it/cpkg/my_meth_result\nStandards-Version: 3.6.2\n\nPackage: test-name\nVersion: 1.2.3\nMaintainer: Unibo Virtlab <info@virtlab.unibo.it>\nDepends: \nArchitecture: all\nPostinst: /tmp/pippopluto\nPreinst: /tmp/pippopluto2\n\nDescription: I'm a short description\n I'm a\n .\n description\n .\n on three lines\n"
  end

end


