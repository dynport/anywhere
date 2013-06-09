module Anywhere
  class ExecutionError < StandardError
    attr_reader :result

    def initialize(result)
      @result = result
    end
  end
end
