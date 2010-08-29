require 'rspec_apigen/meta_helper'
require 'rspec_apigen/method'
require 'rspec_apigen/argument'
require 'rspec_apigen/fixture'
require 'rspec_apigen/given'

module RSpec::ApiGen

  def fixture(name,desc=nil, &block)
    before(:all) do
      val = instance_eval(&block)
      self.class.send(:class_variable_set, "@@#{name}".to_sym, val)
    end

    let(name) do
      self.class.send(:class_variable_get, "@@#{name}".to_sym)
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

    given = nil
    context "Given" do
      given = Given.new(self, method, args, &given_block)
    end 

    # todo should be possible to have several Then
    context "Then #{then_desc}" do
      self.send(:define_method, :given) { given }
      self.send(:define_method, :arg) { given.arg }
      # use the same subject as we used when calling the method on it in the given block
      #      self.send(:define_method, :subject) { given.subject }

      context "Return #{describe_return[:example_desc][0]}" do
        subject { given.return }

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
          current_context.subject { clazz }
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
