module SessionTestHelper
  def sign_in_as(character, non_perishable: false)
    Current.session = character.sessions.create!(expires_at: non_perishable ? nil : Session.expires_in.from_now)

    ActionDispatch::TestRequest.create.cookie_jar.tap do |cookie_jar|
      cookie_jar.signed[:session_id] = Current.session.token
      cookies["session_id"] = cookie_jar[:session_id]
    end
  end

  def sign_out
    Current.session&.destroy!
    cookies.delete("session_id")
  end

  def get_signed_cookie(cookie_name)
    jar = ActionDispatch::Cookies::CookieJar.build(@request, cookies.to_hash)

    jar.signed[cookie_name]
  end
end

ActiveSupport.on_load(:action_dispatch_integration_test) do
  include SessionTestHelper
end
