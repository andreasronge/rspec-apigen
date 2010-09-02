# Make the RSpec::ApiGen module available in all 'spec/api' test folders automatically'

RSpec.configure do |c|
 c.extend RSpec::ApiGen, :example_group => { :file_path => %r{\b/spec/api} }
end
