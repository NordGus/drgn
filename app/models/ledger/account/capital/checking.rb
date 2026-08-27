class Ledger::Account::Capital::Checking < Ledger::Account
  include WithHistorySubaccount

  validates :type, inclusion: { in: %w[Ledger::Account::Capital::Checking] }
  validates :parent_id, absence: true
  validates :currency, presence: true, exclusion: { in: %w[multi] }
end
