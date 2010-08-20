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
    "Account balance: #{balance} #{currency}"
  end
end
