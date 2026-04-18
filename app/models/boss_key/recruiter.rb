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
  scope :with_access, -> { where.not(deleted_at: nil).where.not(access_level: :no) }
end
