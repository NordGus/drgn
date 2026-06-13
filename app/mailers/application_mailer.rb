class ApplicationMailer < ActionMailer::Base
  layout "mailer"

  default from: "from@example.com"

  rescue_from Mechanic::Environmental::PostOffice::NotConfiguredError do |_exception|
    # TODO: implement a notification toast to communicate to users that the email client is not configured to the
    #   responsible characters
  end
end
