# frozen_string_literal: true
class EventChannel < ApplicationCable::Channel
  def subscribed
    @event = Event.find(params[:id])

    # TODO: use user identifier from cookie
    @user_identifier = ('a'..'z').to_a.sample(16).join

    temp_stream_name = String(@event) + '|' + @user_identifier
    stream_from temp_stream_name

    Song.where(event: @event).each do |song|
      ActionCable.server.broadcast(temp_stream_name, song)
    end

    stream_for @event
  end

  def submit_song(data)
    return if Song.exists?(uri: data['uri'], event: @event)

    song = Song.create!(name: data['name'], artist: data['artist'], art: data['art'], duration: data['duration'],
                        uri: data['uri'], event: @event)

    EventChannel.broadcast_to(@event, song)
  end

  def vote(data)
    user_identifier = @user_identifier
    song_id = data['song']

    song = Song.find_by(id: song_id, event: @event)
    return if song.nil?

    if data['upvote']
      song.upvote(user_identifier)
    else
      song.downvote(user_identifier)
    end

    EventChannel.broadcast_to(@event, song)
  end
end
