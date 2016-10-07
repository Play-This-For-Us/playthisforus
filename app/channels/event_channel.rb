class EventChannel < ApplicationCable::Channel
  def subscribed
    event = Event.find(params[:id])

    # Unique stream for pseudo-unicast of the initial data. I hate myself for this.
    temp_stream_name = String(event) + '|' + ('a'..'z').to_a.shuffle[0, 16].join
    stream_from temp_stream_name

    Song.where(event: event).each do |song|
      ActionCable.server.broadcast(temp_stream_name, song)
    end

    stream_for event
  end

  def receive(data)
    event = Event.find(params[:id])

    Song.create!(name: data['name'], artist: data['artist'], art: data['art'], duration: data['duration'],
                    uri: data['uri'], score: 0, event: event)

    data['score'] = 0 # so that the client gets a score to show
    EventChannel.broadcast_to(event, data)
  end
end