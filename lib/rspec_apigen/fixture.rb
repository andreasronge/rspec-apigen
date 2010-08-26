module RSpec::ApiGen
  class Fixture
    attr_reader :description
    attr_reader :create_proc
    attr_reader :destroy_proc

    #def initialize(description, create_proc, destroy_proc = nil)
    def initialize(description, &block)
      @description = description && ""

      # initialize this instance
      self.instance_eval &block
    end

    def create(&block)
      block.nil? ? @create_proc.call : @create_proc = block
    end

    def destroy(&block)
      block.nil? ? @destroy_proc.call : @destroy_proc = block
    end

  end

end