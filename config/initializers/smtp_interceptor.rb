# frozen_string_literal: true

class SmtpInterceptor
  def self.delivering_email(message)
    post_office = Mechanic::Environmental::PostOffice.instance

    fail Mechanic::Environmental::PostOffice::NotConfiguredError unless post_office.configured?

    message.delivery_method.settings.merge!(
      address: post_office.address,
      port: post_office.port,
      domain: post_office.domain,
      user_name: post_office.user_name,
      password: post_office.password,
      authentication: post_office.authentication,
      enable_starttls_auto: post_office.enable_starttls_auto,
      open_timeout: post_office.open_timeout,
      read_timeout: post_office.read_timeout
    )
  end
end

ActionMailer::Base.register_interceptor(SmtpInterceptor)
