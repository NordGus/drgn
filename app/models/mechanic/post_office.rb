class Mechanic::PostOffice < Mechanic
  validates :type, inclusion: { in: %w[Mechanic::PostOffice] }

  has_one :address, class_name: "Mechanic::PostOffice::Address", foreign_key: :mechanic_id, dependent: :destroy
  has_one :port, class_name: "Mechanic::PostOffice::Port", foreign_key: :mechanic_id, dependent: :destroy
  has_one :username, class_name: "Mechanic::PostOffice::Username", foreign_key: :mechanic_id, dependent: :destroy
  has_one :password, class_name: "Mechanic::PostOffice::Password", foreign_key: :mechanic_id, dependent: :destroy

  def configured?
    configured = address.present? && port.present? && username.present? && password.present?

    unless configured

    end

    configured
  end
end
