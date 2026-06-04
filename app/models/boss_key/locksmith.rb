##
# BossKey::Locksmith represents the access level a character has to the Locksmith access control manager feature of DRGN
class BossKey::Locksmith < BossKey
  enum :access_level, {
    no: 0,
    manage: 1
  }, default: :no, prefix: :with, suffix: :access, validates: true

  validates :type, inclusion: { in: %w[BossKey::Locksmith] }

  scope :deactivated, -> { where.not(deleted_at: nil) }
  scope :with_access, -> { where(deleted_at: nil).where.not(access_level: :no) }
  scope :with_whom_can_be_broadcasted, -> { includes(holder: [ :locksmith_key ]).with_access }

  def can_access?
    deleted_at.nil? && !with_no_access?
  end

  def settings_controller_name
    "boss_keys"
  end

  def can_manage?
    with_manage_access?
  end
end
