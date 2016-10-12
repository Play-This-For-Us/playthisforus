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
        song: songID,
        user_identifier: @getCookie "user_identifier"
      }

  getCookie: (cname) ->
    name = cname + '='
    ca = document.cookie.split(';')
    i = 0
    while i < ca.length
      c = ca[i]
      while c.charAt(0) == ' '
        c = c.substring(1)
      if c.indexOf(name) == 0
        return c.substring(name.length, c.length)
      i++
    ''
