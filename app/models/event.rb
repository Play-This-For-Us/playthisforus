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
#  currently_playing   :boolean          default(FALSE), not null
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

  scope :currently_playing, -> { where(currently_playing: true) }

  def avatar_image
    # we currently have 5 default images
    "events/#{(id % 4) + 1}.jpg"
  end

  def current_queue
    self.songs.active_queue.ranked
  end

  def can_queue_song?
    current_queue.positive?
  end

  def next_song
    current_queue.first
  end

  def queue_next_song
    return unless next_song
    song = next_song

    auth_user
    spotify_playlist.add_tracks!([song.to_spotify_track])
    song.remove_from_queue
    send_currently_playing
  end

  def check_queue
    return unless should_queue_next_song?
    queue_next_song
  end

  def channel_name
    "event-#{self.id}"
  end

  def show_current_song?
    self.currently_playing && song_is_playing?
  end

  def currently_playing_song
    self.songs.where.not(queued_at: nil).order(queued_at: :desc).first
  end

  def send_currently_playing
    ActionCable.server.broadcast self.channel_name, action: 'current-song', data: currently_playing_song
  end

  private

  def song_is_playing?
    song = currently_playing_song
    return false unless song.present?
    (song.queued_at + (song.duration / 1000).seconds) >= (Time.now.utc)
  end

  def auth_user
    # TODO(skovy) make this cleaner
    self.user.spotify
  end

  def should_queue_next_song?
    song = currently_playing_song

    # if there are not songs currently playing or played, queue up!
    return true unless song.present?

    (song.queued_at + (song.duration / 1000).seconds) <= (Time.now.utc + 20.seconds)
  end

  def spotify_playlist
    user_id = self.user.spotify_attributes['id']
    playlist_id = self.spotify_playlist_id
    @spotify_playlist ||= RSpotify::Playlist.find(user_id, playlist_id)
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
