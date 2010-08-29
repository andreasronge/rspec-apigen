module RSpec::ApiGen
  class Argument
    attr_reader :name, :description

    def initialize(name, description, accept_block = false)
      @name = name
      @description = description
      @accept_block = accept_block
    end

    def accept_block?
      @accept_block      
    end

    def to_s
      "Arg #{name}"
    end
  end

end