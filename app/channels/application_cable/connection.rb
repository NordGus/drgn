module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_character

    def connect
      set_current_character || reject_unauthorized_connection
    end

    private
      def set_current_character
        if (session = Session.includes(:character).find_by(token: cookies.signed[:session_id]))
          self.current_character = session.character
        end
      end
  end
end
