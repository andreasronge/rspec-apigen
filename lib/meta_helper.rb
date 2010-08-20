module MetaHelper
  def self.singleton_of(obj)
    class << obj; self; end
  end

  def self.create_instance_method(obj, name, &block )
    singleton_of(obj).send(:define_method, name, &block)
  end
  
end