require 'meta_helper'

module RSpec::ApiGen

  class Fixture
    attr_reader :description
    attr_reader :create_proc
    attr_reader :destroy_proc
    
    def initialize(description, create_proc, destroy_proc = nil)
      @description = description
      @create_proc = create_proc
      @destroy_proc = destroy_proc
    end

    def create
      @create_proc.call
    end
  end


  def add_fixture(name, clazz, description=nil, &block)
    def clazz.fixture(name)
      @_fixtures[name.to_sym]
    end unless clazz.respond_to?(:fixture)

    dsl = Object.new
    dsl_meta = class << dsl; self; end
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


  class Argument
    attr_reader :name, :description
    def initialize(name, description)
      @name = name
      @description = description
    end

    def to_s
      "Arg #{name}"
    end
  end

  def arg(name, description='')
    Argument.new(name, description)
  end


  
  def singleton_of(obj)
    class << obj; self; end
  end


  def create_given_obj(given_args)
    given_obj = Object.new
    given_args.each_pair do |key,value|
      # create a reader method on the given obj
      MetaHelper.create_instance_method(given_obj, key) { value }
    end
    MetaHelper.create_instance_method(given_obj, :method_missing) do |meth|
      fail("Tried to get an undefined given argument #{meth}")
    end

    given_obj
  end

  
  def execute_given_block(args, given_block)
    given_args = {}
    arg_obj = Object.new

    # for each arguments
    args.find_all { |a| a.kind_of?(Argument) }.each do |arg|
      MetaHelper.create_instance_method(arg_obj, "#{arg.name}=") do |val|
        given_args[arg.name] = val
      end
    end

    # add some error checking if accessing an undefined argument
    MetaHelper.create_instance_method(arg_obj, :method_missing) do |meth|
      fail("Tried to set an undefined argument #{meth}")
    end

    # create the arg method on a new object
    obj = Object.new
    MetaHelper.create_instance_method(obj, :arg) { arg_obj }

    # populate the given_args variable using the created new Object as context
    obj.instance_eval(&given_block)

    given_args
  end

  def static_method(method, param, &block)
    args = param[:args]
    context "##{method}", describe_args(args) do

      # create method to set the describe_return variable
      describe_return = nil
      MetaHelper.create_instance_method(self, :describe_return) do |*example_desc, &example|
        describe_return = {:example => example, :example_desc => example_desc}
      end

      # create method to set the given_block variable
      given_block = nil
      MetaHelper.create_instance_method(self, :given) { |&b| given_block = b}

      # eval and set the given_block and describe_return variables
      clazz = describes
      subject { clazz }
      self.instance_eval(&block)

      # if we have a given block then we can get the given arguments values
      given_args = given_block ? execute_given_block(args, given_block) : {}

      # for each argument we replace the args with the real value
      args.collect! {|arg| arg.kind_of?(Argument)? given_args[arg.name] : arg}

      context "then returns #{describe_return[:example_desc][0]}" do
        subject { clazz.send(method, *args) }

        # create a given object which returns the given arguments
        given_obj = create_given_obj(given_args)
        # add a method given  
        MetaHelper.create_instance_method(self, :given) { given_obj }

        # run the example in the describe_return block
        self.instance_eval(&describe_return[:example])
      end if describe_return
    end
  end

  def create_fixtures_in_arguments(args)
    args.collect do |a|
      a.kind_of?(Fixture) ? a.create : a
    end
  end

  def describe_args(args)
    "(#{args.collect { |x| x.kind_of?(Argument)? x.name : "#{x}:#{x.class}" }.join(',')})"
  end

  def static_methods
    clazz = describes
    metaclass = class << self
      self
    end
    # TODO It comes in the wrong order
    describe "Public Static Methods" do
      def_methods = clazz.methods - Object.methods + %w[new]
      def_methods.each do |meth_name|
#        MetaHelper.create_instance_method(self, meth_name) do |*args, &example_group|
        metaclass.send(:define_method, meth_name) do |*args, &example_group|
          if example_group # UGLY, since we have modified wrong new method
            static_method(meth_name, :args => args, &example_group)
          else
            super
          end
        end
      end
      yield
    end
  end

  def instance_methods
    clazz = describes
    metaclass = class << self
      self
    end
    describe "Public Instance Methods" do
      def_methods = clazz.instance_methods - Object.instance_methods
      def_methods.each do |meth_name|
        metaclass.send(:define_method, meth_name) do |*args, &example_group|
          if example_group # UGLY, since we have modified the wrong method
            instance_method(meth_name, :args => args, &example_group)
          else
            super
          end
        end
      end
      yield
    end
    end

  end
