require "spec_helper"

describe "Anywhere::Base" do
  subject(:base) { Anywhere::Base.new }
  it { should_not be_nil }

  describe "root?" do
    subject do
      base.stub(:execute) { double("output", stdout: "root") }
      base.root?
    end

    it { should be_true }

    describe "not being root" do
      subject do
        base.stub(:execute) { double("output", stdout: "user") }
        base.root?
      end

      it { should_not be_true }
    end
  end

end
