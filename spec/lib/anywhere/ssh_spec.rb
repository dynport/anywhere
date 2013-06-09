require "spec_helper"
require "anywhere/ssh"

describe "Anywhere::SSH" do
  subject(:ssh) { Anywhere::SSH.new("test.host", "root") }
  it { should_not be_nil }

  it { subject.host.should eq("test.host") }
  it { subject.user.should eq("root") }
end

