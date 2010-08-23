module RSpec::ApiGen
  class Given
    attr_reader :subject # contains the block to initialize the subject (or nil)
    attr_reader :args # contains name of argument and its value
    attr_reader :arg # the DSL object used to set the args

    # list_of_args - the list of arguments current method accept
    # When the given block is evaluated in this method
    # the Given#args will return a hash of name or argument and its value.
    def initialize(list_of_args, &block)
      @args = {}
      @arg = Object.new
      args = @args # so we can access it under closure

      list_of_args.find_all { |a| a.kind_of?(Argument) }.each do |arg|
        MetaHelper.create_singleton_method(@arg, "#{arg.name}=") do |val|
          args[arg.name] = val
        end
      end
      self.instance_eval(&block) if block
    end

    def subject(&block)
      puts "init subject #{block}"
      @subject = block
    end
  end
end