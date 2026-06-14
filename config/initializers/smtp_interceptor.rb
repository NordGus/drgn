# frozen_string_literal: true

class SmtpInterceptor
  def self.delivering_email(message)
    post_office = Mechanic::Environmental::PostOffice.instance!

    message.delivery_method.settings.merge!(
      address: post_office.address.value,
      port: post_office.port.value,
      domain: post_office.domain.value,
      user_name: post_office.user_name.value,
      password: post_office.password.value,
      authentication: post_office.authentication.value,
      enable_starttls: post_office.enable_starttls_auto.value,
      open_timeout: post_office.open_timeout.value,
      read_timeout: post_office.read_timeout.value
    )
  rescue ActiveRecord::ActiveRecordError, StandardError => e
    Rails.logger.error "SMTPInterceptor: #{e.message}"

    raise Mechanic::Environmental::PostOffice::NotConfiguredError
  end
end

ActionMailer::Base.register_interceptor(SmtpInterceptor)
