module RSpec::ApiGen

  class Method
    def arg(name, description='')
      Argument.new(name, description)
    end
  end
  
end