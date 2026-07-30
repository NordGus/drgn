class Mechanic::PostOffice < Mechanic
  include PasswordLockable

  validates :type, inclusion: { in: %w[Mechanic::PostOffice] }

  default_scope { includes(:address, :port, :username, :password, :disable_configuration_errors_notification) }

  has_one :address, class_name: "Mechanic::PostOffice::Address", foreign_key: :mechanic_id, dependent: :destroy
  has_one :port, class_name: "Mechanic::PostOffice::Port", foreign_key: :mechanic_id, dependent: :destroy
  has_one :username, class_name: "Mechanic::PostOffice::Username", foreign_key: :mechanic_id, dependent: :destroy
  has_one :password, class_name: "Mechanic::PostOffice::Password", foreign_key: :mechanic_id, dependent: :destroy
  has_one :disable_configuration_errors_notification, class_name: "Mechanic::PostOffice::DisableConfigurationErrorsNotification", foreign_key: :mechanic_id, dependent: :destroy

  accepts_nested_attributes_for :address, reject_if: :all_blank, allow_destroy: false
  accepts_nested_attributes_for :port, reject_if: :all_blank, allow_destroy: false
  accepts_nested_attributes_for :username, reject_if: :all_blank, allow_destroy: false
  accepts_nested_attributes_for :password, reject_if: :all_blank, allow_destroy: false
  accepts_nested_attributes_for :disable_configuration_errors_notification, reject_if: :all_blank, allow_destroy: false

  attribute :unlocked_by, type: :character, default: nil

  def configured?
    configured = address.present? && port.present? && username.present? && password.present?

    OnNotConfiguredJob.perform_later(Time.current) unless configured

    configured
  end

  def test_connection(new_settings = {})
    assign_attributes(new_settings)

    return false unless valid?

    smtp = Net::SMTP.new(self.address.value, self.port.value)

    smtp.enable_starttls_auto

    smtp.open_timeout = 5
    smtp.read_timeout = 5

    smtp.start(user: self.username.value, password: self.password.value, authtype: :plain) do |_connection|
      # If we get here, connection + auth succeeded.
      # `connection` auto-closes (QUIT) when the block exits.
    end

    true
  rescue Net::SMTPAuthenticationError => e
    errors.add(:base, :connection_failed, reason: e.message)

    false
  rescue Net::SMTPServerBusy => e
    errors.add(:base, :connection_failed, reason: e.message)

    false
  rescue Net::SMTPSyntaxError, Net::SMTPFatalError, Net::SMTPUnknownError => e
    errors.add(:base, :connection_failed, reason: e.message)

    false
  rescue Net::OpenTimeout, Net::ReadTimeout => e
    errors.add(:base, :connection_failed, reason: e.message)

    false
  rescue SocketError, Errno::ECONNREFUSED => e
    errors.add(:base, :connection_failed, reason: e.message)

    false
  rescue OpenSSL::SSL::SSLError => e
    errors.add(:base, :connection_failed, reason: e.message)

    false
  end

  def update_settings(new_settings = {}, post_master: Current.character)
    update_outcome = false

    assign_attributes(new_settings.except(:confirmation_password))

    return true unless settings_have_changed?

    transaction do
      touch

      update!(new_settings.to_h.merge(
        unlocked_by: post_master,
        from_dangerous_action: true
      ))

      update_outcome = true
    rescue StandardError => e
      Rails.logger.debug e.message
      Rails.logger.debug e.backtrace.join("\n")

      raise ActiveRecord::Rollback
    end

    OnSettingsUpdatedJob.perform_later(Time.current) if update_outcome

    update_outcome
  end

  def settings_have_changed?
    changed? || address.changed? || port.changed? || username.changed? || password.changed? || disable_notification.changed?
  end

  private

  def record_was_unlocked?
    unlocked_by.present? && unlocked_by.password_padlock.unlock_for_dangerous_action(confirmation_password)
  end
end
