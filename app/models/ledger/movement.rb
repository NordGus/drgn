class Ledger::Movement < ApplicationRecord
  belongs_to :from, class_name: "Ledger::Ledger", foreign_key: :from_id, inverse_of: :outflows, counter_cache: :outflows_count
  belongs_to :to, class_name: "Ledger::Ledger", foreign_key: :to_id, inverse_of: :inflows, counter_cache: :inflows_count
  belongs_to :creator, class_name: "Character", foreign_key: :creator_id

  validates :type, presence: true
  validates :from_id, presence: true
  validates :to_id, presence: true, comparison: { other_than: :from_id }
  validates :creator_id, presence: true
  validates :issued_at, presence: true
  validates :executed_at, comparison: { greater_than_or_equal_to: :issued_at }, if: -> { executed_at.present? }

  scope :active, -> { where(deleted_at: nil) }
  scope :executed, -> { where.not(executed_at: nil) }
  scope :pending, -> { where(executed_at: nil) }
end
