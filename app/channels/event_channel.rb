# frozen_string_literal: true
class EventChannel < ApplicationCable::Channel
  def subscribed
    @event = Event.find(params[:id])

    stream_from @event.channel_name
    stream_from @event.channel_name + '|' + current_user.to_s

    broadcast_current_queue
    @event.send_currently_playing
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
      ActionCable.server.broadcast @event.channel_name + '|' + current_user.to_s, action: 'add-song', data: song
    end
  end

  def unique_channel
    @unique_channel ||= "#{@event}|#{current_user}"
  end

  def current_authed_user
    User.find_by(id: current_user)
  end
end
