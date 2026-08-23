class Ledger::Movement::Transfer < Ledger::Movement
  validates :type, inclusion: { in: %w[Ledger::Movement::Transfer] }
end
