class Ledger::Account < ApplicationRecord
  belongs_to :parent, class_name: "Ledger::Account", optional: true
  belongs_to :created_by, class_name: "Character"

  has_rich_text :description

  has_many :children, class_name: "Ledger::Account", foreign_key: :parent_id
end
