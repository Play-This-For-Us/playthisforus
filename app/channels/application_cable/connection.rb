# frozen_string_literal: true
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      # current_user will be nil if not authenticated or a guest with a proper
      # guest cookie
      self.current_user = find_verified_user
    end

    protected

    def authenticated_user
      @authenticated_user_cookie ||= User.find_by(id: cookies.signed['user.id'])
    end

    def unauthenticated_user
      @unauthenticated_user_cookie ||= cookies.permanent[:user_identifier]
    end

    def find_verified_user
      if authenticated_user.present?
        authenticated_user.id # use the authenticated user's id
      else
        unauthenticated_user if unauthenticated_user.present? && unauthenticated_user.length == 40
      end
    end
  end
end
