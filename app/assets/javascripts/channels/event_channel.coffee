class App.EventChannel
  constructor: (@received) ->
    @eventId = window.eventId;

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

  # send data over the channel
  send: (data) =>
    @eventChannel.send(data)
