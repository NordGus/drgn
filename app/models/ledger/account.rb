class Ledger::Account < ApplicationRecord
  belongs_to :creator, class_name: "Character", foreign_key: :creator_id
  belongs_to :parent, class_name: "Ledger::Account", optional: true, foreign_key: :parent_id, inverse_of: :subaccounts

  enum :currency, {
    multi: 0,
    eur: 1,
    usd: 2,
    gbp: 3
  }, suffix: true, default: :multi, allow_nil: false

  has_many :subaccounts, class_name: "Ledger::Account", foreign_key: :parent_id, dependent: :destroy, inverse_of: :parent
  has_many :outflows, class_name: "Ledger::Movement", foreign_key: :from_id, inverse_of: :from, dependent: :destroy
  has_many :inflows, class_name: "Ledger::Movement", foreign_key: :to_id, inverse_of: :to, dependent: :destroy

  has_rich_text :description

  normalizes :name, with: ->(name) { name.strip }

  validates :type, presence: true
  validates :name, presence: true
  validates :creator_id, presence: true
  validates :parent_id, comparison: { other_than: :id } # prevents circular associations
end
