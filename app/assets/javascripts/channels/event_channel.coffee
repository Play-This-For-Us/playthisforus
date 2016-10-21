class App.EventChannel
  constructor: (@pushSong) ->
    @eventId = window.eventId
    @eventChannel = @subscribeWithReceive()

  subscribe: ->
    App.cable.subscriptions.create { channel: "EventChannel", id: @eventId }

  subscribeWithReceive: ->
    App.cable.subscriptions.create { channel: "EventChannel", id: @eventId },
      received: (data) =>
        if data.action && (data.action == 'add-song' || data.action == 'update-song')
          @pushSong(data.data)
        else if data.action && data.action == 'remove-song'
  
        else
          console.log('Unexpected chanel action.')

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
