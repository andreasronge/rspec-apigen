$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'rspec-apigen'

RSpec.configure do |c|
 c.extend RSpec::ApiGen
end


#$LOAD_PATH.unshift File.dirname(__FILE__)