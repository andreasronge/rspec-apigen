$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'rspec'
require 'spec_helper'


class Account < Array
  attr_accessor :balance, :currency
  def initialize(balance=0, currency = 'USD')
    @balance = balance
    @currency = currency
#    puts "Create account #{balance} #{currency}"
  end

  alias_method :union, :&
  
end


describe Account do
  describe "Public Class Methods" do
    static_method(:new, :args=>[]) do
      return_value("Account with 0 USD") do
        it("has #balance == 0") { subject.balance.should == 0}
        it("has #currency == 'USD") { subject.currency.should == 'USD'}
      end
    end

    static_method(:new, :args=>[50, 'USD']) do
      return_value("Account with 50 USD") do
        it("has #balance == 50") { subject.balance.should == 50}
        it("has #currency == 'USD") { subject.currency.should == 'USD'}
      end
    end

  end


# TODO
#  instance_method(:union, :args =>[[1,2,3]], :use_context => 'empty') do
#    context
#    return_value {should be_empty}
#  end


#  describe "#union ([1,2,3]:Array)" do
#    context "when empty" do
#      subject { Foo.new }
#      context "return value" do
#        it do
#          should be_empty
#        end
#        it { should be_kind_of(Array) }
#      end
#    end
#  end
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
