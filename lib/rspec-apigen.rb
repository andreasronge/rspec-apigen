module RSpec::ApiGen

  def static_method(method, param, &block)
    args = param[:args]
    context "##{method}", describe_args(args) do
      metaclass = class << self; self; end # get the singleton class for current object
      return_value = nil
      metaclass.send(:define_method, :return_value) do |*example_desc, &example|
        return_value = {:example => example, :example_desc => example_desc}
      end
      clazz = describes
      subject { clazz }
      self.instance_eval(&block)
      context "return value: #{return_value[:example_desc][0]}" do
        subject { clazz.new(*args) }
        self.instance_eval(&return_value[:example])        
        #return_values.each { |ret| it(*ret[:ret_param], &ret[:example]) }
      end if return_value
    end
  end


  def describe_args(args)
    "(#{args.collect{|x| "#{x}:#{x.class}"}.join(',')})"
  end
end
