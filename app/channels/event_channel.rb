# frozen_string_literal: true
class EventChannel < ApplicationCable::Channel
  def subscribed
    @event = Event.find(params[:id])

    puts String(current_user)
    temp_stream_name = String(@event) + '|' + String(current_user)
    stream_from temp_stream_name

    puts "COUNT #{@event.songs.count}"
    @event.songs.each do |song|
      puts song
      ActionCable.server.broadcast(@event, song)
    end

    stream_for @event

    puts current_user
  end

  def submit_song(data)
    puts data
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
end
