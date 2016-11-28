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
  validates :join_code, presence: true, uniqueness: true, length: { minimum: JOIN_CODE_LENGTH }, format: { with: /\A[a-z0-9\-_]+\z/ }

  has_many :songs

  scope :currently_playing, -> { where(currently_playing: true) }

  def placeholder_avatar_image
    # we currently have 5 default images
    "events/#{(id % 4) + 1}.jpg"
  end

  def avatar_image
    self.image_url.present? ? self.image_url : placeholder_avatar_image
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
    # if there is no next song then try to generate some
    unless next_song || !self.pnator_enabled
      apply_pnator(self.user, true, 3)
    end

    # if there wasn't a song left and playlistinator failed
    return true unless next_song
    song = next_song

    auth_user
    spotify_playlist.add_tracks!([song.to_spotify_track])
    song.remove_from_queue
    send_currently_playing

    return true # Spotify didn't error
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

  def send_currently_playing(channel: self.channel_name)
    return false unless show_current_song?
    current_song_json = currently_playing_song.as_json
    current_song_json[:time_remaining] = ((currently_playing_song.queued_at + (currently_playing_song.duration / 1000).seconds) - Time.now.utc).in_milliseconds
    ActionCable.server.broadcast channel, action: 'current-song', data: current_song_json
  end

  def apply_pnator(authed_user, bypass_auth, num_songs)
    # You must be the owner and there must be some songs to seed from
    return unless (bypass_auth || (authed_user && self.user == authed_user)) &&
                  self.songs.all.count.positive? && self.pnator_enabled

    seed_tracks = self.songs.last(5).pluck(:uri).map { |uri| uri.split(':')[-1] }
    pnator_popularity = (self.pnator_popularity * 100).round
    recs = RSpotify::Recommendations.generate(limit: num_songs, seed_tracks: seed_tracks,
                                              target_energy: self.pnator_energy,
                                              target_speechiness: self.pnator_speechiness,
                                              target_danceability: self.pnator_danceability,
                                              target_valence: self.pnator_happiness,
                                              target_popularity: pnator_popularity)

    recs.tracks.each do |t|
      next if Song.exists?(uri: t.uri, event: self)

      song = Song.create!(name: t.name, artist: t.artists[0].name, art: t.album.images[0]['url'], duration: t.duration_ms,
                          uri: t.uri, event: self)

      ActionCable.server.broadcast self.channel_name, action: 'add-song', data: song
    end
  end

  def set_join_code
    self.join_code = generate_join_code
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

    (song.queued_at + (song.duration / 1000).seconds) <= (Time.now.utc + 5.seconds)
  end

  def spotify_playlist
    user_id = self.user.spotify_attributes['id']
    playlist_id = self.spotify_playlist_id
    @spotify_playlist ||= RSpotify::Playlist.find(user_id, playlist_id)
  end

  def generate_join_code
    loop do
      token = (0...JOIN_CODE_LENGTH).map { ('a'..'z').to_a[rand(26)] }.join
      break token unless Event.where(join_code: token).exists?
    end
  end
end
