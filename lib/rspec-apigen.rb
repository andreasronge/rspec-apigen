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


  def create_given_obj(given_args)
    given_obj = Object.new
    given_args.each_pair do |key, value|
      # create a reader method on the given obj
      MetaHelper.create_singleton_method(given_obj, key) { value }
    end
    MetaHelper.create_singleton_method(given_obj, :method_missing) do |meth|
      fail("Tried to get an undefined given argument #{meth}")
    end

    given_obj
  end


  def run_scenario(method, args, block)
    # have we defined any scenarios ?
    MetaHelper.create_singleton_method(self, :scenario) do |*scenario_desc, &scenario_block|
      context "Scenario #{scenario_desc[0]}" do
        run_scenario(method, args, scenario_block)
      end
    end

    # create method to set the describe_return variable
    describe_return = nil
    MetaHelper.create_singleton_method(self, :returns) do |*example_desc, &example|
      describe_return = {:example => example, :example_desc => example_desc}
    end

    # create method to set the given_block variable
    given_block = nil
    MetaHelper.create_singleton_method(self, :given) { |&b| given_block = b }

    # eval and set the given_block and describe_return variables
    self.instance_eval(&block)

    # create the subject which we will test with the given method,
    # unless specified in a given DSL block use as default the same as the one described in the DSL
    subject_obj = describes

    # process the given block DSL
    given = Given.new(args, &given_block)

    # check the DSL specified an subject proc, if so create a new subject_obj
    subject_obj = given.subject.call if given.subject
    
    subject { subject_obj }

    # for each argument we replace the args with the real value
    args.collect! { |arg| arg.kind_of?(Argument) ? given.args[arg.name] : arg }

    ret_value = nil
    it "accept arguments: #{args.join(',')}" do
      ret_value = subject_obj.send(method, *args)
    end if describe_return # todo refactoring

    context "then returns #{describe_return[:example_desc][0]}" do
      subject { ret_value }

      # create a given object which returns the given arguments
      given_obj = create_given_obj(given.args)
      # add a method given
      MetaHelper.create_singleton_method(self, :given) { given_obj }

      # run the example in the describe_return block
      self.instance_eval(&describe_return[:example])
    end if describe_return
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
