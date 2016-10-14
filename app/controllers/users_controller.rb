# frozen_string_literal: true
class UsersController < ApplicationController
  before_action :auth_user

  def show
    @user = User.find(params[:id])
    @events = @user.events
  end

  def spotify
    spotify_user = RSpotify::User.new(request.env['omniauth.auth'])

    if current_user.update!(spotify_attributes: spotify_user.to_hash)
      redirect_to current_user, notice: 'Nice! You have successfully authenticated with Spotify.'
    else
      redirect_to current_user, error: 'Oh snap! Something didn\'t go correctly'
    end
  end

  private

  def auth_user
    redirect_to new_user_session_path unless user_signed_in?
  end
end
