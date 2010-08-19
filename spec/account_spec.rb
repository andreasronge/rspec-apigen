require 'spec_helper'



describe Account do

  add_fixture(:account_50, Account) do
    create {
      puts "Create called on account"
      Account.new 50, 'USD'
    }
  end

  puts Account.fixture(:account_50).create

  static_methods do
    new do
      scenario 'Create default account'
      return_value("Account with 0 USD") do
#        it_behaves_like "Account with 0 USD" can also be used
        it("has #balance == 0") { subject.balance.should == 0 }
        it("has #currency == 'USD") { subject.currency.should == 'USD' }
      end
    end

    # can also use the static_method instead of calling with new
    static_method(:new, :args=>[50, 'USD']) do
      scenario "Create account with given amount and currency"
      return_value("Account with 50 USD") do
        it("has #balance == 50") { subject.balance.should == 50 }
        it("has #currency == 'USD") { subject.currency.should == 'USD' }
      end
    end
  end

  instance_methods do
    transfer(5, 'USD') do
      given(Account.fixture(:account_50)) do   # given -> on_subject
        # TODO - scenario 'Create a transfer from ', Account.fixture(:account_50)
        return_value("A transfer of 5 USD from Account with 50 USD") do
          it { should be_kind_of(TransferDSL) }
        end

        describe_fixture(:account_50, "should be modified") do
          it { should == Account.fixture(:account_50).create.balance}
        end
        it "balance should not have been modified" do
          subject.balance.should == Account.fixture(:account_50).create.balance
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

