class Ledger::Account::Capital::Checking < Ledger::Account
  validates :type, inclusion: { in: %w[Ledger::Account::Capital::Checking] }
  validates :parent_id, absence: true
end
