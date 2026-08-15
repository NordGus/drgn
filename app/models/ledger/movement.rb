class Ledger::Movement < ApplicationRecord
  validate :type, presence: true
  validate :source_amount, presence: true
  validate :destination_amount, presence: true
  validate :source_account_id, presence: true
  validate :destination_account_id, presence: true, comparison: { other_than: :source_account_id }
  validate :issue_date, presence: true
  validate :execution_date, comparison: { greater_than_or_equal_to: :issue_date, if: :execution_date_present? }

  belongs_to :source_account, class_name: "Ledger::Account", foreign_key: :source_account_id
  belongs_to :destination_account, class_name: "Ledger::Account", foreign_key: :destination_account_id
end
