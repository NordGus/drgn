# frozen_string_literal: true

module Ledger::Account::WithHistorySubaccount
  extend ActiveSupport::Concern

  included do
    has_one :history, class_name: "Ledger::Account::History", dependent: :destroy, foreign_key: :parent_id, inverse_of: :parent
  end
end
