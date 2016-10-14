# frozen_string_literal: true
class UsersController < ApplicationController
  before_action :auth_user

  def show
    @user = User.find(params[:id])
    @events = @user.events
  end

  def spotify
    spotify_user = RSpotify::User.new(request.env['omniauth.auth'])
    # Now you can access user's private data, create playlists and much more

    # Access private data
    spotify_user.country #=> "US"
    spotify_user.email   #=> "example@email.com"
  end

  private

  def auth_user
    redirect_to new_user_session_path unless user_signed_in?
  end
end
