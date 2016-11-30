class App.EventChannel
  constructor: (@pushSong, @removeSong, @updateCurrentSong, @clear) ->
    @eventId = window.eventId
    @eventChannel = @subscribeWithReceive()
    @alert = new App.Alert()

  subscribe: ->
    App.cable.subscriptions.create { channel: "EventChannel", id: @eventId }

  subscribeWithReceive: ->
    App.cable.subscriptions.create { channel: "EventChannel", id: @eventId },
      received: (data) =>
        if data.alert && data.alert.text && data.alert.type
          @alert.update(data.alert.text, data.alert.type)

        if data.action && (data.action == 'add-song' || data.action == 'update-song')
          @pushSong(data.data)
        else if data.action && data.action == 'remove-song'
          @removeSong(data.data)
        else if data.action && data.action == 'current-song'
          @updateCurrentSong(data.data)
        else if data.action
          console.log('Unexpected chanel action.')
      , disconnected: @clear, connected: @clear

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

  pnator: =>
    @eventChannel.perform 'pnator'

  saveSong: (songID) =>
    @eventChannel.perform 'save_song',
      {
        song: songID
      }
