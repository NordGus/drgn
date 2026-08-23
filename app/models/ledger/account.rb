class Ledger::Account < ApplicationRecord
  belongs_to :creator, class_name: "Character", foreign_key: :creator_id

  has_rich_text :description

  normalizes :name, with: ->(name) { name.strip }

  validates :type, presence: true
  validates :name, presence: true
  validates :creator_id, presence: true

  has_many :outflows, class_name: "Ledger::Movement", foreign_key: :from_id, inverse_of: :from, dependent: :destroy
  has_many :inflows, class_name: "Ledger::Movement", foreign_key: :to_id, inverse_of: :to, dependent: :destroy
end
