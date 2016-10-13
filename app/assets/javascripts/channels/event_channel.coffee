class App.EventChannel
  constructor: (@received) ->
    @eventId = window.eventId

    if @received
      @eventChannel = @subscribeWithReceive()
    else
      @eventChannel = @subscribe()

  subscribe: ->
    App.cable.subscriptions.create { channel: "EventChannel", id: @eventId }

  subscribeWithReceive: ->
    App.cable.subscriptions.create { channel: "EventChannel", id: @eventId },
      received: (data) =>
        @received(data)

  submitSong: (data) =>
    @eventChannel.perform 'submit_song', data

  # send data over the channel
  send: (data) =>
    @eventChannel.send data

  vote: (songID, upvote) =>
    @eventChannel.perform 'vote',
      {
        upvote: upvote,
        song: songID
      }
