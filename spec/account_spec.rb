require 'spec_helper'


class Account
  attr_accessor :balance, :currency

  def initialize(balance=0, currency = 'USD')
    @balance = balance
    @currency = currency
#    puts "Create account #{balance} #{currency}"
  end

  def transfer(amount, currency)
#    puts "called transfer with #{amount} #{currency}"
    TransactionBuilder.new
  end
  def to_s
    "Account #{balance} #{currency}"
  end
end

class TransactionBuilder

end

describe Account do


  describe "Public Class Methods" do
    static_method(:new, :args=>[]) do
      return_value("Account with 0 USD") do
#        it_behaves_like "Account with 0 USD"
        it("has #balance == 0") { subject.balance.should == 0 }
        it("has #currency == 'USD") { subject.currency.should == 'USD' }
      end
    end

    static_method(:new, :args=>[50, 'USD']) do
      return_value("Account with 50 USD") do
        it("has #balance == 50") { subject.balance.should == 50 }
        it("has #currency == 'USD") { subject.currency.should == 'USD' }
      end
    end

  end

  describe "Public Instance Methods" do
    instance_method(:transfer, :args =>[5, 'USD']) do
      given(Account.new(50, 'USD')) do
        return_value("A transfer of 5 USD from Account with 50 USD") do
          it("should return a TransactionBuilder") { should be_kind_of(TransactionBuilder) }
        end
        it "does not modify balance" do
          subject.balance.should == 50
        end
      end
    end
  end
end


#    it_behaves_like "Account with 0 USD"
#  share_examples_for "Account with 0 USD" do
#    it("has #balance == 0") { subject.balance.should == 0}
#    it("has #currency == 'USD") { subject.currency.should == 'USD'}
#  end

