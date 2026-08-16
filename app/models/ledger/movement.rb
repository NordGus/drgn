class Ledger::Movement < ApplicationRecord
  validates :type, presence: true
  validates :source_amount, presence: true
  validates :destination_amount, presence: true
  validates :source_account_id, presence: true
  validates :destination_account_id, presence: true, comparison: { other_than: :source_account_id }
  validates :issue_date, presence: true
  validates :execution_date, comparison: { greater_than_or_equal_to: :issue_date, if: :execution_date? }

  belongs_to :source_account, class_name: "Ledger::Account", foreign_key: :source_account_id
  belongs_to :destination_account, class_name: "Ledger::Account", foreign_key: :destination_account_id
end
