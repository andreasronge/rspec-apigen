require 'spec_helper'

# Inspiration for Fixtures
# http://eggsonbread.com/2010/05/25/speed-up-your-specs-with-set/
# http://github.com/bmabey/database_cleaner
# http://blog.lawrencepit.com/2009/06/08/machinery-to-create-object-graphs-and-speed-up-tests/
# http://github.com/lachie/hornsby


describe TransferDSL do

  # demonstrate that we can use the normal RSpec methods like 'let' inside the blocks below:
  let(:usd_50) { Account.new(50, 'USD')}
  let(:usd_10) { Account.new(10, 'USD')}
  
  static_methods do
    new(arg(:source_account), arg(:amount), arg(:currency)) do
      Given do
        arg.source_account = usd_50
        arg.amount   = 5
        arg.currency = 'USD'
      end

      Return("An TransferDSL instance with initialized source account, amount and currency") do
        it { subject.source_account.balance.should == usd_50.balance } 
      end
    end
  end

  instance_methods do
    to(arg(:target_account)) do
      subject{ TransferDSL.new(usd_50, 10, 'USD') }
      Given do
        arg.target_account = usd_10
      end
      Then "it should add money on the target account" do
        it ("should add money to the target account"){ arg.target_account.balance.should == usd_10.balance + 10}
      end
    end
  end

  
end
