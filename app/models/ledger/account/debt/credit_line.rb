class Ledger::Account::Debt::CreditLine < Ledger::Account
  include WithHistorySubaccount

  validates :type, inclusion: { in: %w[Ledger::Account::Debt::CreditLine] }
  validates :parent_id, absence: true
  validates :currency, presence: true, exclusion: { in: %w[multi] }

  # finances payments are modeled as [Ledger::Account::Debt::Loan] for ease of modeling
  has_many :financed_payments, class_name: "Ledger::Account::Debt::Loan", foreign_key: :parent_id, inverse_of: :parent
end
