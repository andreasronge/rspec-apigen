require 'spec_helper'


describe RSpec::ApiGen do
  instance_methods do
    static_methods(arg_block(:block)) do
      Description "describes all static methods"

      Given do
        puts "in given"
        subject.stub!(:describes).and_return("HOJ HOJ")
        arg.block do
         # puts "Set kalle in #{self.object_id}"
          @kalle = 'foo'
        end

      end
      Then do
        #puts "subject #{given.subject.object_id}"
        #given.subject.instance_eval{ puts "kalle=#{@kalle}"}
      end
    end
  end
end
