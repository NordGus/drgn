# frozen_string_literal: true

class SMTPInterceptor
  def self.delivering_email(message)
    post_office = Mechanic::PostOffice.instance!

    return unless post_office.configured?

    message.delivery_method.settings.merge!(
      address: post_office.address.value,
      port: post_office.port.value,
      user_name: post_office.username.value,
      password: post_office.password.value,
      authentication: :plain,
      enable_starttls_auto: true,
      open_timeout: 5,
      read_timeout: 5
    )
  end
end

ActionMailer::Base.register_interceptor(SMTPInterceptor)
