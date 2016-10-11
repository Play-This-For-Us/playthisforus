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
    unless Song.exists?(uri: data['uri'], event: @event)
      song = Song.create!(name: data['name'], artist: data['artist'], art: data['art'], duration: data['duration'],
                          uri: data['uri'], event: @event)

      EventChannel.broadcast_to(@event, song)
    end
  end

  def vote(data)
    # TODO: way to set vote to 0

    user_identifier = @user_identifier
    song_id = data['song']

    song = Song.find_by(id: song_id, event: @event)

    unless song.nil?
      vote = Vote.find_by(user_identifier: user_identifier, song: song)

      if vote.nil?
        Vote.create!(user_identifier: user_identifier, vote: data['upvote'] ? 1 : -1, song: song)
      else # if the vote already exists, update the score
        if data['upvote']
          vote.upvote
        else
          vote.downvote
        end
      end

      EventChannel.broadcast_to(@event, song)
    end
  end
end
