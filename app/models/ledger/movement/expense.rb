class Ledger::Movement::Expense < Ledger::Movement
  validates :type, inclusion: { in: %w[Ledger::Movement::Expense] }
end
