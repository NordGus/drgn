class Ledger::Movement::Income < Ledger::Movement
  validates :type, inclusion: { in: %w[Ledger::Movement::Income] }
end
