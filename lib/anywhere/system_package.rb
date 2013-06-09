module Anywhere
  class SystemPackage
    attr_reader :name, :version, :arch

    class << self
      def from_list(list)
        list.split("\n").map do |line|
          name_and_arch, version = line.strip.split("\t")
          name, arch = name_and_arch.split(":")
          self.new(name, version, arch)
        end
      end
    end

    def initialize(name, version, arch = nil)
      @name = name
      @version = version
      @arch = arch
    end
  end
end
