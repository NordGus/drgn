##
# Mechanic::Environmental::PostOffice is the mechanic responsible for delivering the emails send by the platform using
# the SMTP settings that the user gave us.
#
#
class Mechanic::Environmental::PostOffice < Mechanic::Environmental
  validates :type, inclusion: { in: %w[Mechanic::Environmental::PostOffice] }

  default_scope { includes(:address, :port, :domain, :user_name, :password, :authentication, :enable_starttls_auto, :open_timeout, :read_timeout) }

  has_one :address, class_name: "Setting::Text::Domain"
  has_one :port, class_name: "Setting::Integer::Port"
  has_one :domain, class_name: "Setting::Text::Domain"
  has_one :user_name, class_name: "Setting::Text::UserName"
  has_one :password, class_name: "Setting::Text::Password"
  has_one :authentication, class_name: "Setting::Enum::Authentication"
  has_one :enable_starttls_auto, class_name: "Setting::Boolean::StarttlsAuto"
  has_one :open_timeout, class_name: "Setting::Integer::Timeout"
  has_one :read_timeout, class_name: "Setting::Integer::Timeout"

  private

  def self.create_default_instance
    fail NotImplementedError, "Mechanic::Environmental::PostOffice needs to be implemented in subclass"
  end
end
