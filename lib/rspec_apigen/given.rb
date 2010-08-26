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

      this = self
      list_of_args.find_all { |a| a.kind_of?(Argument) }.each do |arg|
        MetaHelper.create_singleton_method(@arg, "#{arg.name}=") do |val|
          args[arg.name] = val
        end
        MetaHelper.create_singleton_method(@arg, "#{arg.name}") do
          this.expectation_value(arg.name)
        end
      end
      self.instance_eval(&block) if block
      @destroy_procs = []
      @call_values = {}
      @expectation_values = {}
    end

    def clean_up
      @call_values = {}
      @expectation_values = {}
      @destroy_procs.each {|x| x.call}
      @destroy_procs = []
      @subject_value = nil
    end
        
    # construct a new value for use in caller argument
    def call_value(arg_name)
      @call_values[arg_name] ||= create_value(arg_name)
    end


    def create_value(arg_name)
      val = @args[arg_name]
      ret = val.respond_to?(:create) ? val.create : val
      @destroy_procs << Proc.new{val.destroy_proc.call(ret)} if val.respond_to?(:destroy) && val.destroy_proc
      ret
    end

    def create_subject
      if @subject_value
        @subject_value
      elsif @subject_fixture
        @subject_value = @subject_fixture.create
        @destroy_procs << Proc.new { @subject_fixture.destroy_proc.call(@subject_value) }
        @subject_value
      else
        @subject_proc.call
      end
    end


    # construct a new or reuse an already constructed value to be used to verify and compare the
    # result after calling the method we want to test
    def expectation_value(arg_name)
      @expectation_values[arg_name] ||= create_value(arg_name)
    end

    # Sets the new subject_proc if a block is given
    # else returns a new subject by calling the subject_proc
    def subject(&block)
      block.nil? ? create_subject : @subject_proc = block
    end

    def subject=(fixture)
      unless fixture.respond_to?(:create) && fixture.respond_to?(:destroy)
        raise "Only allowed to set subject to a fixture (unless a block is provided)"
      @subject_fixture = fixture
    end

    def subject_proc
      @subject_proc
    end
  end
end