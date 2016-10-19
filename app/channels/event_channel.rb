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

  private

  def broadcast_current_queue
    @event.songs.active_queue.each do |song|
      ActionCable.server.broadcast(unique_channel, song)
    end
  end

  def unique_channel
    @unique_channel ||= "#{@event}|#{current_user}"
  end
end
