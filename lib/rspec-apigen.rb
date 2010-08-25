require 'rspec_apigen/meta_helper'
require 'rspec_apigen/method'
require 'rspec_apigen/argument'
require 'rspec_apigen/fixture'
require 'rspec_apigen/given'

module RSpec::ApiGen

  def add_fixture(name, clazz, description=nil, &block)
    def clazz.fixture(name)
      @_fixtures[name.to_sym]
    end unless clazz.respond_to?(:fixture)

    dsl = Object.new
    dsl_meta = class << dsl;
      self;
    end
    create_block = nil
    dsl_meta.send(:define_method, :create) do |&b|
      create_block = b
    end
    dsl.instance_eval &block

    clazz.instance_eval do
      @_fixtures ||= {}
      @_fixtures[name.to_sym] = Fixture.new(description, create_block)
    end
  end


  def run_scenario(method, args, block)
    # have we defined any scenarios ?
    MetaHelper.create_singleton_method(self, :Scenario) do |*scenario_desc, &scenario_block|
      context "Scenario #{scenario_desc[0]}" do
        run_scenario(method, args, scenario_block)
      end
    end

    # create method to set the describe_return variable
    describe_return = nil
    MetaHelper.create_singleton_method(self, :Return) do |*example_desc, &example|
      describe_return = {:example => example, :example_desc => example_desc}
    end

    # create method to set the given_block variable
    given_block = nil
    MetaHelper.create_singleton_method(self, :Given) { |&b| given_block = b }


    # create method to set the given_block variable
    then_block = nil
    then_desc  = nil
    MetaHelper.create_singleton_method(self, :Then) { |*desc, &b| then_block = b; then_desc = desc[0] if desc.size > 0}

    # eval and set the given_block and describe_return variables
    self.instance_eval(&block)


    #  if there are no then_block or describe_return then there is nothing to do
    return if describe_return.nil? && then_block.nil?

    # create the subject which we will test with the given method,
    # if there is no given subject in the DSL then it will default to the create a proc for creating a class
    # which will be used to test static methods.
    # If there given proc then it will return an instance of the instance under test and call an instance methods
    # which we will test
    given = Given.new(args, describes, &given_block)

    # check the DSL specified an subject proc, if so create a new subject_obj
    subject &given.subject_proc

    # for each argument we replace the args with the real value
    args.collect! { |arg| arg.kind_of?(Argument) ? given.args[arg.name] : arg }

    ret_value = nil


    context "Given" do
    it "accept arguments: #{args.join(',')}" do
      # create a new subject
      subj = given.subject
      # call the method on this instance which will will test
      ret_value = subj.send(method, *args)
    end 

    end

    context "Then #{then_desc}" do
      self.send(:define_method, "given") do
        given
      end
      context "Return #{describe_return[:example_desc][0]}" do
        subject { ret_value }

        self.instance_eval(&describe_return[:example])
      end if describe_return

      self.instance_eval(&then_block) if then_block
    end
  end

  def create_scenarios_for(method, param, &block)
    args = param[:args]
    context "##{method}", describe_args(args) do
      run_scenario(method, args, block)
    end
  end

  def describe_args(args)
    "(#{args.collect { |x| x.kind_of?(Argument) ? x.name : "#{x}:#{x.class}" }.join(',')})"
  end

  def static_methods(&block)
    clazz = describes
    describe "Public Static Methods" do
      static_context = Method.new

      # TODO - how do I find which methods was defined on the clazz and not inherited ?
      def_methods = clazz.public_methods - Object.methods + %w[new]
      current_context = self

      # add methods on the context - one for each public static method
      def_methods.each do |meth_name|
        MetaHelper.create_singleton_method(static_context, meth_name) do |*args, &example_group|
          current_context.create_scenarios_for(meth_name, :args => args, &example_group)
        end
      end
      static_context.instance_eval(&block)
    end
  end

  def instance_methods(&block)
    clazz = describes
    describe "Public Instance Methods" do
      meth_ctx = Method.new

      # TODO - how do I find which methods was defined on the clazz and not inherited ?
      def_methods = clazz.public_instance_methods - Object.public_instance_methods
      current_context = self
      def_methods.each do |meth_name|
        MetaHelper.create_singleton_method(meth_ctx, meth_name) do |*args, &example_group|
          current_context.create_scenarios_for(meth_name, :args => args, &example_group)
        end
      end
      meth_ctx.instance_eval(&block)
    end
  end
end
