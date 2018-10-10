require 'spec_helper'

# must consist only of lower case letters (a-z), digits (0-9), plus (+) and minus (-) signs, and periods (.). 
# They must be at least two characters long and must start with an alphanumeric character.
describe "Package validations" do
  it "package name correct (no space allowed)" do
    package = FactoryBot.build(:package)
    package.name = 'uno due tre'
    expect(package).not_to be_valid
  end

  it "package name correct (at last 2 character)" do
    package = FactoryBot.build(:package)
    package.name = 'u'
    expect(package).not_to be_valid
  end

  it "package name correct (start with alphanumeric character)" do
    package = FactoryBot.build(:package)
    package.name = '+pippo'
    expect(package).not_to be_valid
  end

  it "package name correct (at last 2 character)" do
    package = FactoryBot.build(:package)
    package.name = 'uno1-due2+tre3.12'
    expect(package).to be_valid
  end


end


