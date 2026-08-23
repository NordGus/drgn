class Ledger::Account::Capital::Saving < Ledger::Account
  validates :type, inclusion: { in: %w[Ledger::Account::Capital::Saving] }
  validates :parent_id, absence: true
end
