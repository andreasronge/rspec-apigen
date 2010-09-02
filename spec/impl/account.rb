class Account
  attr_accessor :balance, :currency

  def initialize(balance=0, currency = 'USD')
    @balance = balance
    @currency = currency
#    puts "Create account #{balance} #{currency}"
  end

  def transfer(amount, currency)
    TransferDSL.new(self, amount, currency)
  end

  def to_s
    "Account balance: #{balance} #{currency}"
  end
end
