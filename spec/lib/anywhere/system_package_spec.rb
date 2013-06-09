require "spec_helper"
require "anywhere/system_package"

describe "Anywhere::SystemPackage" do
  subject(:package) do
    Anywhere::SystemPackage.new("zlib1g-dev", "1:1.2.3.4.dfsg-3ubuntu4")
  end

  it { should_not be_nil }

  it { subject.name.should eq("zlib1g-dev") }
  it { subject.version.should eq("1:1.2.3.4.dfsg-3ubuntu4") }

  describe "#from_list" do
    subject(:packages) do
      Anywhere::SystemPackage.from_list(FIXTURES_PATH.join("packages.txt").read)
    end

    it { should be_kind_of(Array) }
    it { subject.count.should eq(387) }

    describe "#first" do
      subject(:first) { packages.first }
      it { subject.name.should eq("acpid") }
      it { subject.version.should eq("1:2.0.10-1ubuntu3") }
    end
  end
end

