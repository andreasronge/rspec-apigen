lib = File.expand_path('../lib/', __FILE__)
puts "LIB = #{lib}"
$:.unshift lib unless $:.include?(lib)
 
require 'rspec-apigen/version'
 
Gem::Specification.new do |s|
  s.name        = "rspec-apigen"
  s.version     = RSpec::ApiGen::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Andreas Ronge"]
  s.email       = ["andreas.ronge@gmail.com"]
  s.homepage    = "http://github.com/andreasronge/rspec-apigen"
  s.summary     = "A plugin for RSpec for generating an API documentation"
  s.description = "Write your API documentation using a custom RSpec DSL instead of using RDoc"
  s.required_rubygems_version = ">= 1.3.6"
  s.add_runtime_dependency "rspec", ">= 2.0.0.beta.20"
 
  s.files        = Dir.glob("{bin,lib}/**/*") + %w(README.rdoc)
  s.require_path = 'lib'
end