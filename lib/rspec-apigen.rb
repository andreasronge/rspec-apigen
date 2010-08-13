module RSpec::ApiGen

  def instance_method(method, param, &block)
    args = param[:args]

    metaclass = class << self; self; end # get the singleton class for current object
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
      metaclass = class << self; self; end # get the singleton class for current object
      return_value_meth = nil
      metaclass.send(:define_method, :return_value) do |*example_desc, &example|
        return_value_meth = {:example => example, :example_desc => example_desc}
      end
      clazz = describes
      subject { clazz }
      self.instance_eval(&block)
      context "return value: #{return_value_meth[:example_desc][0]}" do
        subject { clazz.new(*args) }
        self.instance_eval(&return_value_meth[:example])
      end if return_value_meth
    end
  end


  def describe_args(args)
    "(#{args.collect{|x| "#{x}:#{x.class}"}.join(',')})"
  end
end
