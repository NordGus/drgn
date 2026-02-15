class Session::ExpireJob < ApplicationJob
  queue_as :default
  limits_concurrency to: 1, key: ->(session) { session }, duration: 1.minute, group: "SessionActions"

  retry_on ActiveRecord::RecordNotFound, wait: 3.seconds, attempts: 10, report: true

  discard_on ActiveRecord::RecordNotFound

  def perform(session, force_expiration: false)
    return :no_session_received unless session.present?
    return :session_is_non_perishable unless session.perishable? || force_expiration

    return :session_still_alive if session_still_alive?(session, force_expiration:)

    session.destroy!

    :session_expired
  end

  private

  def session_still_alive?(session, force_expiration:)
    return false if force_expiration

    Time.current - session.created_at < Session.expires_in
  end
end
