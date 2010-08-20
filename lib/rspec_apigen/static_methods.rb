module RSpec::ApiGen

  class StaticMethods
    def arg(name, description='')
      Argument.new(name, description)
    end
  end
  
end