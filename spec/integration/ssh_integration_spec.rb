require "spec_helper"
require "anywhere/ssh"

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
    @user = "vagrant"
    host = "192.168.34.12"
    port = 22

    @runner = Anywhere::SSH.new(host, @user, port: port)
    @runner.logger = NullLogger.new
    @path = "/tmp/test.txt"
  end

  let(:runner) { @runner }

  describe "#whoami" do
    it { runner.whoami.should eq(@user) }
  end

  describe "#home_dir" do
    it { runner.home_dir.should eq("/root") }
  end

  describe "#extract_tar" do
    let(:path) { FIXTURES_PATH.join("arch.tgz") }

    it "extracts the provided path" do
      runner.extract_tar(path, "/tmp/anywhere/tar")
      runner.execute("ls /tmp/anywhere/tar").stdout.split("\n").should eq(["a.txt", "b.txt"])
      runner.execute("cat /tmp/anywhere/tar/a.txt").stdout.should eq("this is a\n")
    end
  end

  describe "#mkdir_p" do
    before :each do
      @runner.execute("rm -Rf /tmp/anywhere")
    end

    it "should create a new directory" do
      @runner.mkdir_p("mkdir -p /tmp/anywhere/test")
      @runner.execute("file /tmp/anywhere/test").stdout.should include("/tmp/anywhere/test: directory")
    end
  end

  describe "#execute" do
    subject { runner.execute("uptime") }
    it { should be_kind_of(Anywhere::Result) }
    it { subject.stdout.should be_kind_of(String) }
    it { subject.stdout.should include("load average") }
    it { subject.stderr.length.should eq(0) }

    describe "with unknwon command" do
      subject(:error) do
        begin
          runner.execute("rgne")
        rescue => err
          err
        end
      end

      it { should be_kind_of(Anywhere::ExecutionError) }

      describe "#result" do
        subject(:result) { error.result }

        it { should_not be_success }
        it { subject.stdout.should eq("") }
        it { subject.stderr.should include("command not found") }
        it { subject.exit_status.should eq(127) }
      end
    end
  end

  describe "execute" do
    subject { runner.execute("uptime") }
    it { should be_kind_of(Anywhere::Result) }
    it { subject.stdout.should be_kind_of(String) }
    it { subject.stdout.should include("load average") }
    it { subject.stderr.length.should eq(0) }

    describe "with command not successful" do
      it { expect { runner.execute("rgne") }.to raise_error(Anywhere::ExecutionError) }
    end
  end

  describe "write_file" do
    before :all do
      @runner.execute("rm -f #{@path}")
    end

    subject { runner.write_file(@path, "hello world") }
    it { should be_success }
    it { runner.execute("cat #{@path}").stdout.should eq("hello world") }
  end

  describe "write big files" do
    before :all do
      @runner.execute("rm -f #{@path}")
      @content = "X" * 2 * 1024 ** 2
      @response = @runner.write_file(@path, @content)
    end

    subject { @response }

    it { @runner.md5sum(@path).should eq("97cdcd9fbaacc9ea373d676e6abce318") }

    it { should be_success }
    it { runner.execute("wc #{@path}").stdout.should be_kind_of(String) }
    it { runner.execute("wc #{@path}").stdout.strip.split(/\s+/).at(2).to_i.should eq(2 * 1024 ** 2) }
    it { runner.execute("cat #{@path}").stdout.should start_with("XXX") }
  end
end
