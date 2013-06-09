require "anywhere/version"
require "anywhere/logger"

module Anywhere
  class << self
    def logger
      @logger ||= Anywhere::Logger.new
    end
  end
end
