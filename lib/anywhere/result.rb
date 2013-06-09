module Anywhere
  class Result
    attr_accessor :cmd, :stdout, :stderr, :exit_status

    def initialize(cmd)
      @cmd = cmd
      @stdout = []
      @stderr = []
    end

    def add_stderr(line)
      @stderr << line
    end

    def add_stdout(line)
      @stdout << line
    end

    def stderr
      @stderr.join("\n")
    end

    def stdout
      @stdout.join("\n")
    end

    def started!(time = Time.now)
      @started = time
    end

    def finished!(time = Time.now)
      @finished = time
    end

    def success?
      @exit_status == 0
    end

    def run_time
      @finished - @started
    end

    def inspect
      parts = ["run_time=#{run_time}"]
      parts << "cmd=<#{@cmd}>"
      parts << "stdout=#{inspect_string(@stdout)}"
      parts << "stderr=#{inspect_string(@stderr)}"
      parts << "exit_status=#{@exit_status}"
      "<" + parts.join(", ") + ">"
    end

    def inspect_string(string)
      if string.empty?
        "<empty>" 
      else
        "<#{string.count} lines, #{string.join(" ").length} chars>"
      end
    end
  end
end
