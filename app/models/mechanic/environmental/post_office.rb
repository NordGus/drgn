##
# Mechanic::Environmental::PostOffice is the mechanic responsible for delivering the emails send by the platform using
# the SMTP settings that the user gave us.
class Mechanic::Environmental::PostOffice < Mechanic::Environmental
  validates :type, inclusion: { in: %w[Mechanic::Environmental::PostOffice] }

  default_scope { includes(:address, :port, :domain, :user_name, :password, :authentication, :enable_starttls_auto, :open_timeout, :read_timeout) }

  has_one :address, class_name: "Setting::Text::Domain", as: :mechanic, dependent: :destroy
  has_one :port, class_name: "Setting::Integer::Port", as: :mechanic, dependent: :destroy
  has_one :domain, class_name: "Setting::Text::Domain", as: :mechanic, dependent: :destroy
  has_one :user_name, class_name: "Setting::Text::UserName", as: :mechanic, dependent: :destroy
  has_one :password, class_name: "Setting::Text::Password", as: :mechanic, dependent: :destroy
  has_one :authentication, class_name: "Setting::Enum::Authentication", as: :mechanic, dependent: :destroy
  has_one :enable_starttls, class_name: "Setting::Boolean::EnableStarttlsAuto", as: :mechanic, dependent: :destroy
  has_one :open_timeout, class_name: "Setting::Integer::Timeout", as: :mechanic, dependent: :destroy
  has_one :read_timeout, class_name: "Setting::Integer::Timeout", as: :mechanic, dependent: :destroy

  private

  def self.create_default_instance!
    new_instance = create!
    new_instance.address.create!(value: "smtp.gmail.com")
    new_instance.port.create!(value: 587)
    new_instance.domain.create!(value: "example.com")
    new_instance.user_name.create!(value: "your-user-name")
    new_instance.password.create!(value: "your-password")
    new_instance.authentication.create!(value: "plain")
    new_instance.enable_starttls_auto.create!(value: true)
    new_instance.open_timeout.create!(value: 5)
    new_instance.open_timeout.create!(value: 5)
  end
end
