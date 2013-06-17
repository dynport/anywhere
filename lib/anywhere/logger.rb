require "rainbow"
require "time"
require "logger"

module Anywhere
  class Logger
    LEVELS = {
      DEBUG:    0,
      INFO:     1,
      WARN:     2,
      ERROR:    3,
      FATAL:    4,
      UNKNOWN:  5
    }

    COLORS = {
      0 => "#6d6d6d", # 109, 109, 109
      1 => "#227000", # 34, 112
      2 => "#f79700", # 247, 151
      3 => "#f00000", # 240, 0
    }

    attr_accessor :prefix
    attr_writer :log_level

    class << self
      def mutex
        @mutex ||= Mutex.new
      end
    end

    def log_level
      @log_level ||= ::Logger::INFO
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

    LEVELS.each do |name, l|
      define_method(name.downcase) do |message|
        return if log_level > l
        prefix = "%05s" % [name.to_s]
        if color = COLORS[l]
          prefix = prefix.color(color)
        end
        print_with_prefix "%s %s" % [prefix, message]
      end
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
