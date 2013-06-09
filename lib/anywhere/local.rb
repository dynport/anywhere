require "anywhere"
require "anywhere/result"
require "anywhere/execution_error"
require "anywhere/base"

module Anywhere
  class Local < Base
    def do_execute(cmd, stdin_data = nil)
      require "open3"
      result = Result.new(cmd)
      result.started!
      Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
        stdin.print stdin_data if stdin_data
        stdin.close
        while true
          streams, _ = IO.select([stdout, stderr], [], [], 1)
          break if streams.nil? || streams.all? { |s| s.eof? }
          streams.compact.each do |stream|
            stream.each do |line|
              if stream == stdout
                result.add_stdout(line.strip)
                logger.info(line) if logger
              elsif stream == stderr
                result.add_stderr(line.strip)
                logger.error(line) if logger
              end
            end
          end
        end
        result.exit_status = wait_thr.value.exitstatus
      end
      result.finished!
      if !result.success?
        raise ExecutionError.new(result)
      end
      result
    end
  end
end
