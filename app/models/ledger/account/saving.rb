class Ledger::Account::Saving < Ledger::Account
  validates :parent_id, absence: true
end
