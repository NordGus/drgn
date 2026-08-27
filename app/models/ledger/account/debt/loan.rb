
class Ledger::Account::Debt::Loan < Ledger::Account
  include WithHistorySubaccount

  validates :type, inclusion: { in: %w[Ledger::Account::Debt::Loan] }

  validate :parent_id_matches_scoped_type, if: :parent_id_changed?
  validates :currency, presence: true, exclusion: { in: %w[multi] }

  # [Ledger::Account::Debt::Loan] can be a subaccount of [Ledger::Account::Debt::CreditLine] to model financed payments
  # on a [Ledger::Account::Debt::CreditLine] in the Ledger Graph
  belongs_to :parent, class_name: "Ledger::Account::Debt::CreditLine", optional: true, foreign_key: :parent_id, inverse_of: :financed_payments

  private

  def parent_id_matches_scoped_type
    return if parent_id.blank?

    errors.add(:parent, :parent_id_must_match_scoped_type, parent_class: self.class.reflect_on_association(:parent).klass) if parent.nil?
  end
end
