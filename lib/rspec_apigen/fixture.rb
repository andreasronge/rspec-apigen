module RSpec::ApiGen
  class Fixture
    attr_reader :description
    attr_reader :create_proc
    attr_reader :destroy_proc

    def initialize(description, create_proc, destroy_proc = nil)
      @description = description
      @create_proc = create_proc
      @destroy_proc = destroy_proc
    end

    def create
      @create_proc.call
    end
  end

end