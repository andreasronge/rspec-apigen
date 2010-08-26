require 'spec_helper'


describe TransferDSL do

  Account.fixture(:USD_50, "Account with 50 USD") do
    create { Account.new(50, 'USD')}
    destroy {|x| puts "Destroy #{x}"}
  end


  TransferDSL.fixture(:transfer_dsl, 'A transfer of 5 USD from Account with 50 USD') do
    create { TransferDSL.new(Account.fixture(:USD_50)) }
    destroy {|x| puts "Destroy #{x}"}
  end


  static_methods do
    new(arg(:source_account)) do
      Given do
        arg.source_account = Account.fixture(:USD_50)
      end
      Return("An TransferDSL instance with initialized source account") do
        it { subject.source_account.balance.should == given.arg.source_account.balance }
      end
    end
  end

  
end
