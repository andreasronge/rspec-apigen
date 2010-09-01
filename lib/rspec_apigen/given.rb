module RSpec::ApiGen
  class Given
    attr_reader :args # contains name of argument and its value
    attr_reader :arg # the DSL object used to set the args
    attr_accessor :subject
    attr_accessor :return

    def set_backtrace(example, e, given_caller)
#      e.backtrace.each { |line| puts "LINE #{line}" }
#      given_caller.each { |line| puts "given_caller #{line}" }
      bt = given_caller.unshift(e.backtrace.first)
      e.set_backtrace(bt)
      example.set_exception(e)
      example.execution_result[:exception_encountered] = bt
    end

    # list_of_args - the list of arguments current method accept
    # When the given block is evaluated in this method
    # the Given#args will return a hash of name or argument and its value.

    def initialize(context, method, list_of_args, given_caller, &block)
      this = self # so we can access it as closure
      @arg = Object.new
      @args = {}
      block_arg = nil
      context.it "no arguments" do
        list_of_args.find_all { |a| a.kind_of?(Argument) }.each do |a|
          MetaHelper.create_singleton_method(this.arg, "#{a.name}=") do |val|
            this.args[a.name] = val
          end
          if (a.accept_block?)
            MetaHelper.create_singleton_method(this.arg, "#{a.name}") do | &block |
              block_arg = block
            end
          else
            MetaHelper.create_singleton_method(this.arg, "#{a.name}") do
              this.args[a.name]
            end
          end
        end

        # create the arguments
        MetaHelper.create_singleton_method(self, :arg) { this.arg }

        begin
          self.instance_eval &block
        rescue Exception => e
          this.set_backtrace(example, e, given_caller)
        end if block

        list_of_args.delete_if { |a| a.kind_of?(Argument) && a.accept_block? }

        # now, the args hash should have been populated
        # for each param we replace the args with the real value
        list_of_args.collect! { |a| a.kind_of?(Argument) ? this.args[a.name] : a }

        example.metadata[:description] = "arguments #{list_of_args.join(', ')}" unless list_of_args.empty?

        # get the subject which we will use to test the method on, and store it so we can check it
        this.subject = subject

        if (block_arg)
          # call the method on this instance which will will test
          this.return = this.subject.send(method, *list_of_args, &block_arg)
        else
          begin
            this.return = this.subject.send(method, *list_of_args)
          rescue Exception => e
            this.set_backtrace(example, e, given_caller)
          end
        end
      end
    end


  end
end