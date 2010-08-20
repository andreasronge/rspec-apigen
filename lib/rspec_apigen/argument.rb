module RSpec::ApiGen
  class Argument
    attr_reader :name, :description

    def initialize(name, description)
      @name = name
      @description = description
    end

    def to_s
      "Arg #{name}"
    end
  end

end