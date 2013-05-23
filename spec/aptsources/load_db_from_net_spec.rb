require 'spec_helper'

describe "Aptsource" do

  before(:all) do
    @a = FactoryGirl.create(:aptsource, {uri: 'http://mozilla.debian.net',
                                         distribution: 'squeeze-backports', 
                                         component: 'iceweasel-release', 
                                         arch: 'binary-i386'})
  end
  
  it "should update database downloading from network" do
    @a.update_db
    @a.packages.where(:name => 'xulrunner-dev').all.should_not be_empty
  end

end


