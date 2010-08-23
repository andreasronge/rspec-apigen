class Account
  attr_accessor :balance, :currency

  def initialize(balance=0, currency = 'USD')
    @balance = balance
    @currency = currency
#    puts "Create account #{balance} #{currency}"
  end

  def self.sune
    puts "SUNE CALLED"
  end
  def transfer(amount, currency)
#    puts "called transfer with #{amount} #{currency}"
    TransferDSL.new(self)
  end
  def to_s
    "Account balance: #{balance} #{currency}"
  end
end
