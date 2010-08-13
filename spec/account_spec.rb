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
  static_methods do
    new do
      return_value("Account with 0 USD") do
#        it_behaves_like "Account with 0 USD" can also be used
        it("has #balance == 0") { subject.balance.should == 0 }
        it("has #currency == 'USD") { subject.currency.should == 'USD' }
      end
    end

    # can also use the static_method instead of calling with new
    static_method(:new, :args=>[50, 'USD']) do
      return_value("Account with 50 USD") do
        it("has #balance == 50") { subject.balance.should == 50 }
        it("has #currency == 'USD") { subject.currency.should == 'USD' }
      end
    end
  end

  instance_methods do
    transfer(5, 'USD') do
      given(Account.new(50, 'USD')) do
        return_value("A transfer of 5 USD from Account with 50 USD") do
          it { should be_kind_of(TransactionBuilder) }
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

