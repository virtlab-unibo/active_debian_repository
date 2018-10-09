require 'spec_helper'

describe "url method for source" do
  
  it "should give correct url for download" do
    a = FactoryBot.build(:aptsource)
    expect(a.url).to eq("http://mi.mirror.garr.it/mirrors/debian/dists/stable/main/binary-amd64/Packages.bz2")
  end

  it "should give correct url for download for source package" do
    a = FactoryBot.build(:aptsource, :arch => 'source')
    expect(a.url).to eq("http://mi.mirror.garr.it/mirrors/debian/dists/stable/main/source/Sources.bz2")
  end

end


