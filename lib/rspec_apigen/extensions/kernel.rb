module Kernel

  # Creates or returns a already defined fixture
  #
  # Example
  #   Person.fixture(:me, "Some description of this fixture ...") do
  #      create { Person.new('andreas' }
  #      destroy { Person.find('andreas').delete }'
  #
  # Example accessing a defined fixture
  #   Person.fixture(:me)
  #
  def fixture(*args, &block)
    raise "Need a name of the fixture - missing argument" if args[0].nil?

    name = args[0].to_sym
    if (block)
      @_fixtures ||= {}
      @_fixtures[name] = RSpec::ApiGen::Fixture.new(args[1], &block)
    else
      @_fixtures[name]
    end
  end

end