require "rspec"

class Foo < Array
  attr_accessor :args
  def initialize(*args)
#   puts "Created foo with args #{args.inspect}"
    args.each {|x| self << x}
  end

  alias_method :union, :&
  
#  def to_s
#    "Foo [#{@args.inspect}]"
#  end
end



module MyMacros

  def static_method(method, param, &block)
    args = param[:args]
    context "##{method}", describe_args(args) do
      metaclass = class << self; self; end # get the singleton class for current object
      return_values = []
      metaclass.send(:define_method, :return_value) do |*ret_param, &example|
        return_values << {:example => example, :ret_param => ret_param}
      end
      clazz = describes
      subject { clazz }
      self.instance_eval(&block)
      context "return value" do
        subject { clazz.new(*args) }
        return_values.each { |ret| it(*ret[:ret_param], &ret[:example]) }
      end
    end
  end


  def describe_args(args)
    "(#{args.collect{|x| "#{x}:#{x.class}"}.join(',')})"
  end
end


describe Foo do
  extend MyMacros

  static_method(:new, :args=>['apa'], :creates_context => 'none empty') do
    return_value { should_not be_nil }
    return_value {should include('apa')  }
    it "should have subject" do
      puts "Subject = #{subject}"
      should be_kind_of(Class)
    end
  end

  instance_method(:union, :args =>[[1,2,3]], :use_context => 'empty') do
    context
    return_value {should be_empty}
  end

  
  describe "#union ([1,2,3]:Array)" do
    context "when empty" do
      subject { Foo.new }
      context "return value" do
        it do
          should be_empty
        end
        it { should be_kind_of(Array)}
      end
    end
  end
#  instance_method(:args) do
#
#  end
  
end

#Spec::Runner.configure do |config|
##  config.use_transactional_fixtures = true
##  config.use_instantiated_fixtures = false
##  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
#  config.extend(ControllerMacros, :type => :controller)
#end
