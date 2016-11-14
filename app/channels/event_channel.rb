# frozen_string_literal: true
class EventChannel < ApplicationCable::Channel
  def subscribed
    @event = Event.find(params[:id])

    stream_from @event.channel_name
    stream_from unique_channel

    broadcast_current_queue
    @event.send_currently_playing(channel: unique_channel)
  end

  def submit_song(data)
    return if Song.exists?(uri: data['uri'], event: @event, queued_at: nil)

    song = Song.create!(
      name: data['name'],
      artist: data['artist'],
      art: data['art'],
      duration: data['duration'],
      uri: data['uri'],
      event: @event
    )

    song.upvote(current_user)

    ActionCable.server.broadcast @event.channel_name, action: 'add-song', data: song

    ActionCable.server.broadcast unique_channel, action: 'add-song', data: with_current_user_vote(song)
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

    # update all guests with the new vote
    ActionCable.server.broadcast @event.channel_name, action: 'update-song', data: song

    # update only the voter with their vote value
    ActionCable.server.broadcast unique_channel, action: 'add-song', data: with_current_user_vote(song)

    # remove song if score is less than -4
    song.destroyer if song.score < -4
  end

  # add a song (by id) to the user's saved songs playlist
  def save_song(data)
    authed_user = current_authed_user
    return unless authed_user && authed_user.user_spotify_authenticated?

    song = Song.find_by(id: data['song'], event: @event)
    return if song.nil?

    authed_user.add_to_saved(song)
  end

  def pnator(_data)
    authed_user = current_authed_user
    @event.apply_pnator(authed_user, false, 10)
  end

  private

  def broadcast_current_queue
    @event.songs.active_queue.each do |song|
      ActionCable.server.broadcast unique_channel, action: 'add-song', data: with_current_user_vote(song)
    end
  end

  def unique_channel
    @unique_channel ||= "#{@event.channel_name}|#{current_user}"
  end

  def current_authed_user
    User.find_by(id: current_user)
  end

  def with_current_user_vote(song)
    song_hash = song.as_json
    vote = Vote.find_by(user_identifier: current_user, song: song)

    song_hash[:current_user_vote] = vote.present? ? vote.vote : 0

    song_hash
  end
end
