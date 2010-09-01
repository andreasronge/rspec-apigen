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

    def self.inspect_args(args)
      args.collect do |x|
        case x
          when Argument
            x.name
          when RSpec::Mocks::Mock
            x.instance_variable_get('@name')
          else
            "#{x}:#{x.class}"
        end
      end
    end

    def self.describe(args)
      "(#{inspect_args(args).join(', ')})"
    end

  end

end