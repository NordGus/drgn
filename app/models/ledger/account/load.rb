class Ledger::Account::Load < Ledger::Account
  validates :parent_id, absence: true
end
