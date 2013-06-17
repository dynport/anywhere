require "net/ssh"
require "anywhere"
require "anywhere/base"
require "anywhere/result"
require "anywhere/execution_error"

module Anywhere
  class SSH < Base
    attr_reader :host, :user

    def initialize(host, user, attributes = {})
      @host = host
      @user = user
      @attributes = attributes.merge(paranoid: false)
    end

    def do_execute(cmd, stdin = nil, stdout = nil)
      result = Result.new(cmd)
      result.started!
      ssh.open_channel do |ch|
        ch.exec cmd do |ch, success|
          raise "could not execute command" unless success
          ch.on_data do |ch, data|
            result.add_stdout data
            if stdout
              stdout << data
            elsif block_given?
              yield(:stdout, data)
            end
          end

          ch.on_extended_data do |ch, type, data|
            result.add_stderr data
            yield(:stderr, data) if block_given?
          end

          ch.on_request("exit-status") do |ch, data|
            result.exit_status = data.read_long
          end
          if stdin
            ch.send_data stdin
            ch.eof!
          end
        end
      end
      ssh.loop
      result.finished!
      if !result.success?
        raise Anywhere::ExecutionError.new(result)
      end
      result
    rescue Net::SSH::AuthenticationFailed
      puts "ERROR: try adding your ssh key to you ssh-agent (ssh-add /path/to/ssh.pem)"
      raise
    end

    def ssh
      @ssh ||= Net::SSH.start(@host, @user, @attributes)
    end
  end
end
