##
# BossKey represents the permissions a character has to the different protected features of DRGN.
#
# @note As long a holder all required BossKey required by the system exists/
# @note All children of this model, meaning implementations, must understant that access_level 0 means no access.
class BossKey < ApplicationRecord
  belongs_to :holder, class_name: "Character", foreign_key: :holder_id

  validates :access_level, presence: true
  validates :holder_id, presence: true, uniqueness: { scope: :type }
  validates :type, presence: true

  scope :deleted, -> { where.not(deleted_at: nil) }
  scope :active, -> { where(deleted_at: nil) }

  def can_access?
    fail NotImplementedError, "each BossKey must implement the #can_access? method"
  end
end
