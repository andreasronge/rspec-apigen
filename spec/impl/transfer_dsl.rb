class TransferDSL

  attr_reader :source_account, :amount, :currency
  
  def initialize(account, amount, currency)
    @source_account = account
    @amount = amount
    @currency = currency
  end

  def to(target_account)
    target_account.balance += @amount
    @source_account.balance -= @amount
  end

  def to_s
    "A Transfer from #{@source_account} with #{@amount}"
  end
end