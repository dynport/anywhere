require "spec_helper"
require "anywhere/local"

describe "Anywhere::Local" do
  before do
    Anywhere.stub(:logger) { double("logger", error: true, info: true) }
  end

  subject(:local) { Anywhere::Local.new }
  it { should_not be_nil }

  describe "whoami" do
    it { subject.whoami.should be_kind_of(String) }
  end

  describe "#execute" do
    subject(:result) { local.execute("ls -la") }

    it { should_not be_nil }
    it { should be_kind_of(Anywhere::Result) }
    it { subject.exit_status.should eq(0) }
    it { subject.stdout.should be_kind_of(String) }

    describe "with command raising an error" do
      subject(:error) do
        caught_err = nil
        begin
          local.execute("echo 1; echo 2 > /dev/stderr; exit 1")
        rescue => err
          caught_err = err
        end
        caught_err
      end

      it { should_not be_nil }
      it { should be_kind_of(Anywhere::ExecutionError) }
      it { subject.result.should be_kind_of(Anywhere::Result) }

      it { subject.result.stdout.should eq("1") }
      it { subject.result.stderr.should eq("2") }
    end
  end
end
