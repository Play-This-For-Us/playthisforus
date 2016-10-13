# frozen_string_literal: true
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    protected

    def find_verified_user
      if verified_user = User.find_by(id: cookies.signed['user.id'])
        verified_user.id
      else
        user_identifier = cookies.permanent[:user_identifier]
        if user_identifier.present? && user_identifier.length == 40
          user_identifier
        end
      end
    end
  end
end
