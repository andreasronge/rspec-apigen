require 'spec_helper'


describe Account do

#  static_methods do
#    new do
#      describe_return("Account with 0 USD") do
#        # it_behaves_like "Account with 0 USD" can also be used
#        it("has #balance == 0") { subject.balance.should == 0 }
#        it("has #currency == 'USD") { subject.currency.should == 'USD' }
#      end
#    end
#
#    # can also use the static_method instead of calling with new
#    new(arg(:amount), arg(:currency)) do
#      scenario 'account and currency has valid values' do
#        given do
#          puts "EVAL SELF #{self}"
#          arg.amount   = 50
#          arg.currency = 'USD'
#        end
#
#        describe_return "an Account with given amount and currency" do
#          it { subject.balance.should == 50 } #given.amount }
#          it { subject.currency.should == 'USD' } # given.currency }
#        end
#      end
#    end
#  end

  instance_methods do
    transfer(arg(:amount), arg(:currency)) do
      scenario 'transfer amount and currency have valid values' do
        given do
          arg.amount = 5
          arg.currency = 'USD'
          subject{Account.new(50,'USD')}
        end
        describe_return "A transfer of 5 USD from Account with 50 USD" do
          it { should be_kind_of(TransferDSL) }
        end

#        describe_subject "should not be modified" do
#          it { balance.should == 50 }
#          it { currency.should == 'USD' }
#        end
      end
    end
  end
end


#    it_behaves_like "Account with 0 USD"
#  share_examples_for "Account with 0 USD" do
#    it("has #balance == 0") { subject.balance.should == 0}
#    it("has #currency == 'USD") { subject.currency.should == 'USD'}
#  end

