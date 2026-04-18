##
# BossKey::Recruiter represents the access level a character has to the Invitations feature of DRGN
class BossKey::Recruiter < BossKey
  enum :access_level, {
    no: 0,
    share: 1,
    invite: 2,
    manage: 3
  }, default: :no, prefix: :with, suffix: :access, validate: true

  validates :type, inclusion: { in: %w[BossKey::Recruiter] }

  scope :deactivated, -> { where.not(deleted_at: nil) }
  scope :with_access, -> { where(deleted_at: nil).where.not(access_level: :no) }

  def with_access?
    deleted_at.nil? && !with_no_access?
  end

  def can_share?
    with_share_access? || with_invite_access? || with_manage_access?
  end

  def can_invite?
    with_invite_access? || with_manage_access?
  end

  def can_revoke?
    with_manage_access?
  end
end
