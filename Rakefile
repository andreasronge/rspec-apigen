$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "rspec-apigen/version"

desc "create the gemspec"
task :build do
  system "gem build rspec-apigen.gemspec"
end
 
desc "release gem to gemcutter"
task :release => :build do
  system "gem push rspec-apigen-#{RSpec::ApiGen::VERSION}"
end