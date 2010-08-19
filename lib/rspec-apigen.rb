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


  def instance_method(method, param, &block)
    args = param[:args]

    metaclass = class << self;
      self;
    end # get the singleton class for current object
    return_value_meth = nil
    metaclass.send(:define_method, :return_value) do |*example_desc, &example|
      return_value_meth = {:example => example, :example_desc => example_desc}
    end

    given_subject = nil
    given_block = nil
    metaclass.send(:define_method, :given) do |object, &b|
      given_subject = object
      given_block = b
    end

    context "##{method}", describe_args(args) do
      self.instance_eval(&block)
      context "Given #{given_subject}" do
        subject { given_subject }
        ret_value = nil
        it "should accept given arguments" do
          ret_value = given_subject.send(method, *args)
        end
        self.instance_eval(&given_block)
        context "return value: #{return_value_meth[:example_desc][0]}" do
          subject { ret_value }
          self.instance_eval(&return_value_meth[:example])
        end if return_value_meth
      end
    end
  end

  def static_method(method, param, &block)
    args = param[:args]
    context "##{method}", describe_args(args) do
      metaclass = class << self;
        self;
      end # get the singleton class for current object
      return_value_meth = nil
      metaclass.send(:define_method, :return_value) do |*example_desc, &example|
        return_value_meth = {:example => example, :example_desc => example_desc}
      end
      clazz = describes
      subject { clazz }
      self.instance_eval(&block)
      context "return value: #{return_value_meth[:example_desc][0]}" do
        new_args = create_fixtures_in_arguments(args)
        new_args.each {|x| puts "NEW ARG #{x}"}
        subject { clazz.send(method, *args) }
        self.instance_eval(&return_value_meth[:example])
      end if return_value_meth
    end
  end

  def create_fixtures_in_arguments(args)
    args.collect do |a|
      a.kind_of?(Fixture) ? a.create : a
    end
  end

  def describe_args(args)
    "(#{args.collect { |x| "#{x}:#{x.class}" }.join(',')})"
  end

  def static_methods
    clazz = describes
    metaclass = class << self
      self
    end
    describe "Public Static Methods" do
      def_methods = clazz.methods - Object.methods + %w[new]
      def_methods.each do |meth_name|
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
