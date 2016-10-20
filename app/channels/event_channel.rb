# frozen_string_literal: true
class EventChannel < ApplicationCable::Channel
  def subscribed
    @event = Event.find(params[:id])

    stream_from unique_channel
    broadcast_current_queue

    stream_for @event
  end

  def submit_song(data)
    return if Song.exists?(uri: data['uri'], event: @event)

    song = Song.create!(name: data['name'], artist: data['artist'], art: data['art'], duration: data['duration'],
                        uri: data['uri'], event: @event)

    EventChannel.broadcast_to(@event, song)
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

    EventChannel.broadcast_to(@event, song)
  end

  def pnator(data)
    authed_user = current_authed_user
    # You must be the owner and there must be some songs to seed from
    return unless authed_user and @event.user == authed_user and @event.songs.all.count > 0

    seed_tracks = @event.songs.pluck(:uri).map{ |uri| uri.split(':')[-1] }
    # TODO Marcus target_popularity
    recs = RSpotify::Recommendations.generate(limit: 10, seed_tracks: seed_tracks,
                                              target_energy: @event.pnator_energy,
                                              target_speechiness: @event.pnator_speechiness,
                                              target_danceability: @event.pnator_danceability,
                                              target_valence: @event.pnator_happiness)

    recs.tracks.each { |t|
      # Don't know how to get URI from RSpotify track
      song = Song.create!(name: t.name, artist: t.artists[0].name, art: t.album.images[0]['url'], duration: t.duration_ms,
                          uri: t.uri, event: @event)

      EventChannel.broadcast_to(@event, song)
    }
  end

  private

  def broadcast_current_queue
    @event.songs.each do |song|
      ActionCable.server.broadcast(unique_channel, song)
    end
  end

  def unique_channel
    @unique_channel ||= "#{@event}|#{current_user}"
  end

  def current_authed_user
    return User.find_by(id: current_user)
  end
end
