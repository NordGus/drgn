require "active_support/concern"

##
# PasswordLockable gives the model the ability to be protected by the password lock of the character or their own key.
#
# Basically adds a state machine-like behaviour to the model so you can make some action considered dangerous at the
# model logic level
module PasswordLockable
  extend ActiveSupport::Concern

  included do
    # We validate that the record is unlocked only when is done from a dangerous action; otherwise it's unnecessary.
    validate :must_be_unlocked, if: -> { from_dangerous_action }

    # Basically the password key used to protect the current model record from modification.
    attribute :confirmation_password, :string, default: nil
    # This flag is used to control whether the record is protected from modification from a dangerous action or not. This
    # is used to control the validation whether the record is unlocked or not.
    attribute :from_dangerous_action, :boolean, default: false
  end

  private

  def must_be_unlocked
    fail NotImplementedError, "remember to implement must_be_unlocked private method in #{self.class}"
  end
end
