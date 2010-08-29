require 'spec_helper'


describe Account do

  static_methods do
    new do
      Return("Account with 0 USD") do
        # it_behaves_like "Account with 0 USD" can also be used
        it("has #balance == 0") { subject.balance.should == 0 }
        it("has #currency == 'USD") { subject.currency.should == 'USD' }
      end
    end

    new(arg(:amount), arg(:currency)) do
      Scenario 'account and currency has valid values' do
        Given do
          arg.amount   = 50
          arg.currency = 'USD'
        end

        Return "an Account with given amount and currency" do
          it { subject.balance.should == 50 } #given.amount }
          it { subject.currency.should == 'USD' } # given.currency }
        end
      end
    end
  end

  instance_methods do
    transfer(arg(:amount), arg(:currency)) do
#      Description 'bla bla bla'
      Scenario 'transfer amount and currency have valid values' do
        subject { Account.new(50, 'USD') }
        Given do
          arg.amount = 5
          arg.currency = 'USD'
        end
        Return "A transfer of 5 USD from Account with 50 USD" do
          it { should be_kind_of(TransferDSL) }
        end
        Then do
          it "should not change subject" do
            given.subject.balance.should == subject.balance
          end
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

