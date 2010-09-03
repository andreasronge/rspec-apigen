module RSpec::ApiGen

  class Method
    def arg(name, description='')
      Argument.new(name, description)
    end

    def arg_block(name, description='')
      Argument.new(name, description, true)
    end

  end
  
end