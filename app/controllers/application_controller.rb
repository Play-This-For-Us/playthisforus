# frozen_string_literal: true
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  add_flash_types :error

  def after_sign_in_path_for(resource)
    user_path(resource)
  end
end
