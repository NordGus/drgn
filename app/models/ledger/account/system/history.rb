class Ledger::Account::System::History < Ledger::Account
  validates :type, inclusion: { in: %w[Ledger::Account::System::History] }
  validates :parent_id, presence: true

  validate :parent_id_matches_scoped_type, if: :parent_id_changed?
  validates :currency, presence: true, inclusion: { in: %w[multi] }

  belongs_to :parent, class_name: "Ledger::Account", optional: true, foreign_key: :parent_id, inverse_of: :history

  private

  def parent_id_matches_scoped_type
    return if parent_id.blank?

    errors.add(:parent, :parent_id_must_match_scoped_type, parent_class: self.class.reflect_on_association(:parent).klass) if parent.nil?
  end
end
