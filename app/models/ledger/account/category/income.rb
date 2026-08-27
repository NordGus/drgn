class Ledger::Account::Category::Income < Ledger::Account
  validates :type, inclusion: { in: %w[Ledger::Account::Category::Income] }
  validates :currency, presence: true, inclusion: { in: %w[multi] }
  validate :parent_id_matches_scoped_type, if: :parent_id_changed?

  belongs_to :parent, class_name: "Ledger::Account", optional: true, inverse_of: :subaccounts

  # subcategories are an exclusive subaccount type for [Ledger::Account::Category]
  has_many :subcategories, class_name: "Ledger::Account::Category::Income", through: :subaccounts

  private

  def parent_id_matches_scoped_type
    return if parent_id.blank?

    errors.add(:parent, :parent_id_must_match_scoped_type, parent_class: self.class.reflect_on_association(:parent).klass) if parent.nil?
  end
end
