class Ledger::Account < ApplicationRecord
  validates :type, presence: true
  validates :name, presence: true
  validates :parent_id, comparison: { other_than: :id }
  validate :theres_no_grandparent_accounts, if: :parent_id?

  belongs_to :parent, class_name: "Ledger::Account", optional: true
  belongs_to :created_by, class_name: "Character"

  has_rich_text :description

  has_many :children, class_name: "Ledger::Account", foreign_key: :parent_id, dependent: :destroy
  has_many :outflows, class_name: "Ledger::Movement", foreign_key: :source_account_id, dependent: :destroy
  has_many :inflows, class_name: "Ledger::Movement", foreign_key: :destination_account_id, dependent: :destroy

  private

  def theres_no_grandparent_accounts
    return if parent_id.nil?

    errors.add(:parent_id, :no_grandparent_account_allowed) if parent.parent_id.present?
  end
end
