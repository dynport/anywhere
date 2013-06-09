require "spec_helper"
require "anywhere/local"

describe "SSH integration spec" do
  class NullLogger
    [:info, :debug, :error].each do |name|
      define_method(name) do |*args|
        captured[name] ||= []
        captured[name] << args
      end
    end

    def captured
      @captured ||= {}
    end
  end

  before :all do
    @runner = Anywhere::Local.new
    @runner.logger = NullLogger.new
    @path = "/tmp/test.txt"
  end

  let(:runner) { @runner }

  describe "#whoami" do
    it { runner.whoami.should be_kind_of(String) }
  end

  describe "porviding data through stdin" do
    subject(:result) do
      runner.execute("cat - > /tmp/test.txt", "hello world")
      runner.execute("cat /tmp/test.txt").stdout
    end

    it { should be_kind_of(String) }
    it { subject.should eq("hello world") }
  end
end
