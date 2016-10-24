# frozen_string_literal: true
class EventChannel < ApplicationCable::Channel
  def subscribed
    @event = Event.find(params[:id])

    stream_from @event.channel_name

    broadcast_current_queue
  end

  def submit_song(data)
    return if Song.exists?(uri: data['uri'], event: @event)

    song = Song.create!(
      name: data['name'],
      artist: data['artist'],
      art: data['art'],
      duration: data['duration'],
      uri: data['uri'],
      event: @event
    )

    ActionCable.server.broadcast @event.channel_name, action: 'add-song', data: song
  end

  def vote(data)
    return unless current_user.present?

    song_id = data['song']
    song = Song.find_by(id: song_id, event: @event)
    return if song.nil?

    if data['upvote']
      song.upvote(current_user)
    else
      song.downvote(current_user)
    end

    ActionCable.server.broadcast @event.channel_name, action: 'update-song', data: song
  end

  def pnator(_data)
    authed_user = current_authed_user
    # You must be the owner and there must be some songs to seed from
    return unless authed_user && @event.user == authed_user && @event.songs.all.count.positive?

    seed_tracks = @event.songs.last(5).pluck(:uri).map { |uri| uri.split(':')[-1] }
    puts(seed_tracks)
    pnator_popularity = (@event.pnator_popularity * 100).round
    recs = RSpotify::Recommendations.generate(limit: 10, seed_tracks: seed_tracks,
                                              target_energy: @event.pnator_energy,
                                              target_speechiness: @event.pnator_speechiness,
                                              target_danceability: @event.pnator_danceability,
                                              target_valence: @event.pnator_happiness,
                                              target_popularity: pnator_popularity)

    recs.tracks.each { |t|
      next if Song.exists?(uri: t.uri, event: @event)

      song = Song.create!(name: t.name, artist: t.artists[0].name, art: t.album.images[0]['url'], duration: t.duration_ms,
                          uri: t.uri, event: @event)

      ActionCable.server.broadcast @event.channel_name, action: 'add-song', data: song
    }
  end

  private

  def broadcast_current_queue
    @event.songs.active_queue.each do |song|
      ActionCable.server.broadcast @event.channel_name, action: 'add-song', data: song
    end
  end

  def unique_channel
    @unique_channel ||= "#{@event}|#{current_user}"
  end

  def current_authed_user
    return User.find_by(id: current_user)
  end
end
