require 'spec_helper'
require 'tmpdir'

describe "Equivs" do

  # delete previous package and create new
  before(:all) do
    @package = FactoryBot.build(:package)
    @equivs = ActiveDebianRepository::Equivs.new(@package, REPO_DIR)
    @expected_file_name = File.join(REPO_DIR, @equivs.package_filename)

    # clean
    File.delete(@expected_file_name) if File.exists? @expected_file_name

    expect(File.exist?(@equivs.create)).to be true
  end

  it "should be extractable with dpkg and contain in /usr/share/doc/... README.Debian" do
    Dir.mktmpdir do |tmp_dir|
      res = `dpkg -x #{@expected_file_name} #{tmp_dir}`
      expect($?.success?).to be true
      debian_readme = File.join(tmp_dir, '/usr/share/doc/', @package.name, 'README.Debian')
      p debian_readme
      expect(File.exist?(debian_readme)).to be true
    end
  end

end

