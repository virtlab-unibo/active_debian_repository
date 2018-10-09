require 'spec_helper'

describe "Aptsource" do
  before(:all) do
    @a = FactoryBot.create(:aptsource, { uri: 'https://download.docker.com/linux/debian',
                                         distribution: 'stretch', 
                                         component: 'stable', 
                                         arch: 'binary-amd64' })
  end
  
  it "should update database downloading from network" do
    @a.update_db
    expect(@a.packages.where(name: 'docker-ce')).not_to be_empty
  end
end


