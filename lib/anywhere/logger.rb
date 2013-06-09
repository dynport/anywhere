require "colorize"
require "time"

module Anywhere
  class Logger
    attr_accessor :prefix

    class << self
      def mutex
        @mutex ||= Mutex.new
      end
    end

    def initialize(attributes = {})
      @attributes = attributes
    end

    def prefix
      @prefix ||= @attributes[:prefix]
    end

    def stream
      @attributes[:stream] ||= STDOUT
    end

    def info(message)
      print_with_prefix "INFO ".green + " #{message}"
    end

    def error(message)
      print_with_prefix "ERROR".red + " #{message}"
    end

    def debug(message)
      print_with_prefix "DEBUG".blue + " #{message}"
    end

    def print_with_prefix(message)
      out = [Time.now.utc.iso8601(6)]
      if prefix.is_a?(String)
        out << prefix
      elsif prefix.respond_to?(:call)
        out << prefix.call
      end
      out << message
      self.class.mutex.synchronize do
        stream.puts out.join(" ")
      end
    end
  end
end
