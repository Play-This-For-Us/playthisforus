# frozen_string_literal: true
# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  spotify_attributes     :text
#

# A registered user of the application
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :events

  serialize :spotify_attributes

  # A basic check to verify that there are attributes stored in spotify
  # attributes. We may want to consider a more "reliable" verification
  def user_spotify_authenticated?
    self.spotify_attributes.present? &&
      self.spotify_attributes.key?('credentials') &&
      self.spotify_attributes['credentials'].key?('refresh_token') &&
      self.spotify_attributes['credentials'].key?('token')
  end

  def spotify
    @spotify ||= RSpotify::User.new(self.spotify_attributes)
  end

  def upvoted_playlist
    unless self.upvote_playlist_id.present?
      @upvoted_playlist = self.spotify.create_playlist!('playthis-upvoted')
      self.upvote_playlist_id = @upvoted_playlist.id
      self.save()
    else
      @upvoted_playlist ||= RSpotify::Playlist::find(spotify.id, self.upvote_playlist_id)
    end

    return @upvoted_playlist
  end

  def add_to_upvoted(song)
    # Ghetto way to prevent duplicates for now
    upvoted_playlist.remove_tracks!(Array(RSpotify::Track.new(song)))

    upvoted_playlist.add_tracks!(Array(RSpotify::Track.new(song)))
  end

  def remove_from_upvoted(song)
    upvoted_playlist.remove_tracks!(Array(RSpotify::Track.new(song)))
  end
end
