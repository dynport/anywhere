require "spec_helper"
require "anywhere/logger"

describe "Anywhere::Logger" do
  subject(:logger) { Anywhere::Logger.new }
  it { should_not be_nil }
  it { subject.prefix.should be_nil }

  it "sets the default log level to INFO" do
    logger.log_level.should eq(Logger::INFO)
  end

  describe "setting the prefix" do
    it "changes the prefix" do
      subject.prefix = "test"
      subject.prefix.should eq("test")
    end
  end

  describe "log levels" do
    let(:stringio) { StringIO.new }
    let(:log_level) { Logger::DEBUG }

    subject(:lines) do
      logger.log_level = log_level
      logger.stub(:stream) { stringio }
      logger.info "log info"
      logger.debug "log debug"
      stringio.rewind
      stringio.read.split("\n")
    end

    it { should be_kind_of(Array) }
    it { subject.count.should eq(2) }
    it { subject.at(0).should include("INFO") }
    it { subject.at(1).should include("DEBUG") }

    describe "with log level being info" do
      let(:log_level) { Logger::INFO }

      it { subject.count.should eq(1) }
      it { subject.at(0).should include("INFO") }
    end

    describe "" do
    end
  end
end

