module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private
    def authenticated?
      resume_session
    end

    def require_authentication
      resume_session || request_authentication
    end

    def resume_session
      Current.session ||= find_session_by_cookie
    end

    def find_session_by_cookie
      session = Session.includes(:character).find_by(token: cookies.signed[:session_id]) if cookies.signed[:session_id]

      # We prevent a session from being resumed if it has expired. We do not destroy it here, because the platform will
      # do it automatically when the Session::ExpireJob job enqueued at session creation is processed or during recurring
      # orphan session cleanup.
      return nil if session.present? && session.expired?

      session
    end

    def request_authentication
      session[:return_to_after_authenticating] = request.url
      redirect_to new_session_path
    end

    def after_authentication_url
      session.delete(:return_to_after_authenticating) || root_url
    end

    def start_new_session_for(character, expires_at: Session.expires_in.from_now)
      character.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip, expires_at:).tap do |session|
        Current.session = session
        cookies.signed.permanent[:session_id] = { value: session.token, httponly: true, same_site: :lax }
        Session::ExpireJob.set(wait_until: session.expires_at).perform_later(session) if session.perishable?
      end
    end

    def terminate_session
      Current.session.destroy
      cookies.delete(:session_id)
    end
end
