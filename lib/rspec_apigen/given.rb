module RSpec::ApiGen
  class Given
    attr_reader :args # contains name of argument and its value
    attr_reader :arg # the DSL object used to set the args
    attr_accessor :subject
    attr_accessor :return

    # list_of_args - the list of arguments current method accept
    # When the given block is evaluated in this method
    # the Given#args will return a hash of name or argument and its value.
    def initialize(context, method, list_of_args, &block)
      this = self # so we can access it as closure
      @arg = Object.new
      @args = {}
      
      context.it "no arguments" do
        list_of_args.find_all { |a| a.kind_of?(Argument) }.each do |a|
          MetaHelper.create_singleton_method(this.arg, "#{a.name}=") do |val|
            this.args[a.name] = val
          end
          MetaHelper.create_singleton_method(this.arg, "#{a.name}") do
            this.args[a.name]
          end
        end

        # create the arguments
        MetaHelper.create_singleton_method(self, :arg) { this.arg }
        self.instance_eval &block if block

        # now, the args hash should have been populated
        # for each param we replace the args with the real value
        list_of_args.collect! { |a| a.kind_of?(Argument) ? this.args[a.name] : a }

        example.metadata[:description] = "arguments #{list_of_args.join(', ')}" unless list_of_args.empty?

        # get the subject which we will use to test the method on, and store it so we can check it
        this.subject = subject

        # call the method on this instance which will will test
        this.return = this.subject.send(method, *list_of_args)
      end
    end

  end

  def describe_args(args)
    "(#{args.collect { |x| x.kind_of?(Argument) ? x.name : "#{x}:#{x.class}" }.join(',')})"
  end

end