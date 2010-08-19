describe TransferDSL do
  #fixtures = {:source_account  => { :description=>'Account with 50 USD', :fixture => Account.new(50, 'USD')}


  add_fixture(:source_account, Account, 'Account with 50 USD') do
    create { Account.new(50,'USD') }
    #destroy {}
  end

  add_fixture(:transfer_dsl, 'A transfer of 5 USD from Account with 50 USD') do
    TransferDSL.new(fixture(:source_account))
  end


  static_methods do
    new(Account.fixture(:source_account)) do
      return_value("An TransferDSL instance with initialized source account") do
        it { subject.amount.should == fixture(:source_account).amount }
        it { subject.source_account.should == fixture(:source_account) }
      end
    end
  end

  
  instance_methods do
    to(Account.fixture(:target_account).as(:fff).description("An empty account")) do
      given(TransferDSL.fixture(:transfer_dsl)) do # on_subject
        describe_fixture :target_account,  "transfer money to the target account" do

        end
        describe_return_value do

        end
        fixture(:target_account, 'transfer') do

        end
        argument(:target_account) do
          it { subject.balance.should == 5 }
          it { subject.currency.should == 'USD' }
        end
        source_account do
          it { subject.balance.should == 45 }
          it { subject.currency.should == 'USD' }
        end
      end
    end

  end
end
