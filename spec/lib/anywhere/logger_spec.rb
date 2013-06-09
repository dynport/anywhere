require "spec_helper"
require "anywhere/logger"

describe "Anywhere::Logger" do
  subject(:logger) { Anywhere::Logger.new }
  it { should_not be_nil }
  it { subject.prefix.should be_nil }

  describe "setting the prefix" do
    it "changes the prefix" do
      subject.prefix = "test"
      subject.prefix.should eq("test")
    end
  end
end

