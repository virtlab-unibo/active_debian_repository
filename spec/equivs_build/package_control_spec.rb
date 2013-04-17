require 'spec_helper'

describe "Equivs control string" do

  REPO = "/tmp"

  before(:each) do
    @package = FactoryGirl.build(:package)
  end

  # in spec_helper abbiamo definito i default di repo.... 
  it "should create correct control string" do
    ActiveDebianRepository::Equivs.new(@package, REPO).control_string.should == "Section: debutils\nPriority: optional\nHomepage: http://example.it/cpkg/my_meth_result\nStandards-Version: 3.6.2\n\nPackage: test-name\nVersion: 1.2.3\nMaintainer: Unibo Virtlab <info@virtlab.unibo.it>\nDepends: \nArchitecture: all\n\n\nDescription: Breve descrizione\n Una lunga description\n .\n su tre righe\n .\n ho detto tre\n"
  end

  # in spec_helper abbiamo definito i default di repo.... 
  it "should create correct control with empty lines in description body" do
    @package.body = "description\n  \ncon spazi\n\nenon spazi"
    ActiveDebianRepository::Equivs.new(@package, REPO).control_string.should == "Section: debutils\nPriority: optional\nHomepage: http://example.it/cpkg/my_meth_result\nStandards-Version: 3.6.2\n\nPackage: test-name\nVersion: 1.2.3\nMaintainer: Unibo Virtlab <info@virtlab.unibo.it>\nDepends: \nArchitecture: all\n\n\nDescription: Breve descrizione\n description\n .\n con spazi\n .\n enon spazi\n"
  end

  it "should create correct control string with a postinst script into it" do
    pkg = ActiveDebianRepository::Equivs.new(@package, REPO)
    @package.add_script(:postinst, '/tmp/pippopluto')
    pkg.control_string.should ==  "Section: debutils\nPriority: optional\nHomepage: http://example.it/cpkg/my_meth_result\nStandards-Version: 3.6.2\n\nPackage: test-name\nVersion: 1.2.3\nMaintainer: Unibo Virtlab <info@virtlab.unibo.it>\nDepends: \nArchitecture: all\nPostinst: /tmp/pippopluto\n\nDescription: Breve descrizione\n Una lunga description\n .\n su tre righe\n .\n ho detto tre\n"
    @package.add_script(:preinst, '/tmp/pippopluto2')
    pkg.control_string.should ==  "Section: debutils\nPriority: optional\nHomepage: http://example.it/cpkg/my_meth_result\nStandards-Version: 3.6.2\n\nPackage: test-name\nVersion: 1.2.3\nMaintainer: Unibo Virtlab <info@virtlab.unibo.it>\nDepends: \nArchitecture: all\nPostinst: /tmp/pippopluto\nPreinst: /tmp/pippopluto2\n\nDescription: Breve descrizione\n Una lunga description\n .\n su tre righe\n .\n ho detto tre\n"
  end

end


