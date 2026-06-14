class Setting::Enum::Authentication < Setting::Enum
  validates :type, inclusion: { in: %w[Setting::Enum::Authentication] }
  validates :mechanic_type, inclusion: { in: %w[Mechanic::Environmental::PostOffice] }
  validates :value, presence: true

  enum :value, { plain: 0, login: 1, cram_md5: 2 }, prefix: nil, default: :plain
end
