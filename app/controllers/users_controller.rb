# frozen_string_literal: true
class UsersController < ApplicationController
  before_action :auth_user

  def show
    @user = User.find(params[:id])
    @events = @user.events
  end

  private

  def auth_user
    redirect_to new_user_session_path unless user_signed_in?
  end
end
