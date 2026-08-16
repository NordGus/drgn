class Ledger::Account::CreditLine < Ledger::Account
  validates :parent_id, absence: true
end
