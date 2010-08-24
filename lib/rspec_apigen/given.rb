module RSpec::ApiGen
  class Given
    attr_reader :args # contains name of argument and its value
    attr_reader :arg # the DSL object used to set the args

    # list_of_args - the list of arguments current method accept
    # When the given block is evaluated in this method
    # the Given#args will return a hash of name or argument and its value.
    def initialize(list_of_args, default_given_subject, &block)
      @args = {}
      @arg = Object.new
      @subject_proc = Proc.new { default_given_subject }
      args = @args # so we can access it under closure

      list_of_args.find_all { |a| a.kind_of?(Argument) }.each do |arg|
        MetaHelper.create_singleton_method(@arg, "#{arg.name}=") do |val|
          args[arg.name] = val
        end
      end
      self.instance_eval(&block) if block
    end

    # Sets the new subject_proc if a block is given
    # else returns a new subject by calling the subject_proc
    def subject(&block)
      block.nil? ? @subject_proc.call : @subject_proc = block
    end

    def subject_proc
      @subject_proc
    end
  end
end