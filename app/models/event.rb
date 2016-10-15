# frozen_string_literal: true
# == Schema Information
#
# Table name: events
#
#  id                  :integer          not null, primary key
#  name                :string           not null
#  description         :text             not null
#  join_code           :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  user_id             :integer
#  spotify_playlist_id :string
#

# An event or party that multiple users can join
class Event < ApplicationRecord
  JOIN_CODE_LENGTH = 8

  belongs_to :user

  validates :name, presence: true
  validates :description, presence: true

  has_many :songs

  has_secure_token :join_code

  # create a random code to join the event
  before_create :set_join_code

  def avatar_image
    # we currently have 5 default images
    "events/#{(id % 4) + 1}.jpg"
  end

  def current_queue
    self.songs
  end

  def next_song
    current_queue.first
  end

  def next_song_to_spotify
    RSpotify::Track.new(next_song)
  end

  def queue_next_song
    spotify_playlist.add_tracks!([next_song_to_spotify])
  end

  private

  def spotify_playlist
    @spotify_playlist ||= RSpotify::Playlist.find(self.user.spotify_attributes['id'], self.spotify_playlist_id)
  end

  def set_join_code
    self.join_code = generate_join_code
  end

  def generate_join_code
    loop do
      token = (0...JOIN_CODE_LENGTH).map { ('a'..'z').to_a[rand(26)] }.join
      break token unless Event.where(join_code: token).exists?
    end
  end
end
