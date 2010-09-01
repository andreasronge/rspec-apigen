module RSpec::ApiGen
  class Given
    attr_reader :args # contains name of argument and its value
    attr_reader :arg # the DSL object used to set the args
    attr_reader :fixtures
    attr_accessor :subject
    attr_accessor :return


    # list_of_args - the list of arguments current method accept
    # When the given block is evaluated in this method
    # the Given#args will return a hash of name or argument and its value.
    def initialize(context, method, list_of_args, given_caller, &block)
      this = self # so we can access it as closure
      @arg = Object.new
      @args = {}
      @fixtures = {}
      block_arg = nil

      list_of_args.find_all { |a| a.kind_of?(Argument) }.each do |a|
        MetaHelper.create_singleton_method(@arg, "#{a.name}=") do |val|
          this.args[a.name] = val
        end
        if (a.accept_block?)
          MetaHelper.create_singleton_method(@arg, "#{a.name}") do | &bl |
            block_arg = bl
          end
        else
          MetaHelper.create_singleton_method(@arg, "#{a.name}") do
            this.args[a.name]
          end
        end
      end

      context.it "no arguments" do
        # create the arguments
        MetaHelper.create_singleton_method(self, :arg) { this.arg }

        # accessor for setting fixture
        MetaHelper.create_singleton_method(self, :fixtures) { this.fixtures }

        begin
          self.instance_eval &block
        rescue Exception => e
          this.set_backtrace(example, e, given_caller)
        end if block

        list_of_args.delete_if { |a| a.kind_of?(Argument) && a.accept_block? }

        # now, the args hash should have been populated
        # for each param we replace the args with the real value
        list_of_args.collect! { |a| a.kind_of?(Argument) ? this.args[a.name] : a }

        example.metadata[:description] = "arguments #{Argument.describe(list_of_args)}" unless list_of_args.empty?

        # get the subject which we will use to test the method on, and store it so we can check it
        this.subject = subject

        begin
          example.execution_result[:exception_encountered] = given_caller

          if (block_arg)
            # call the method on this instance which will will test
            this.return = this.subject.send(method, *list_of_args, &block_arg)
          else
            this.return = this.subject.send(method, *list_of_args)
          end
        rescue Exception => e
          this.set_backtrace(example, e, given_caller)
        end

      end
    end

    def set_backtrace(example, e, given_caller)
      trace = e.backtrace

      # TODO very ugly - don't know how to filter rspec own backtrace
      # remove all lines containing ../lib/rspec
      trace.delete_if {|line| line =~ /\/lib\/rspec\//}
      trace.delete_if {|line| line =~ /\/rubygems\/custom_require/}
      trace.delete_if {|line| line =~ /\/bin\/rspec/}

      bt = trace + given_caller
      e.set_backtrace(bt)
      example.set_exception(e)
      example.execution_result[:exception_encountered] = bt
    end

  end
end