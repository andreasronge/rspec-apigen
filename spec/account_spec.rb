require 'spec_helper'



describe Account do
             # jokka palm

  static_methods do
    new do
      describe_return("Account with 0 USD") do
        # it_behaves_like "Account with 0 USD" can also be used
        it("has #balance == 0") { subject.balance.should == 0 }
        it("has #currency == 'USD") { subject.currency.should == 'USD' }
      end
    end

    # can also use the static_method instead of calling with new
    new(arg(:amount), arg(:currency)) do
#    scenario 'account and currency has valid values' do
      given do 
        arg.amount   = 50
        arg.currency = 'USD'
#        subject{}
      end

      describe_return "an Account with given amount and currency" do
        it { subject.balance.should == 50 }    #given.amount }
        it { subject.currency.should == 'USD'} # given.currency }
      end
    end
#  end
  end
end



#    it_behaves_like "Account with 0 USD"
#  share_examples_for "Account with 0 USD" do
#    it("has #balance == 0") { subject.balance.should == 0}
#    it("has #currency == 'USD") { subject.currency.should == 'USD'}
#  end

