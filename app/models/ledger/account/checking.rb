class Ledger::Account::Checking < Ledger::Account
  validates :parent_id, absence: true
end
