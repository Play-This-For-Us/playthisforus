class App.Event
  # qrButtonSelect: string to select the QR code show button in the DOM
  # joinCodeSelector: string to select the event join code element in the DOM
  constructor: (@qrButtonSelector, joinCodeSelector) ->
    # Convert the qr button selector to a jquery element
    @qrButtonSelector = $(@qrButtonSelector)

    # Get the join code string
    @joinCode = $(joinCodeSelector).html().trim()

    @qrButtonSelector.popover({
      html: true,
      content: =>
        # Have the popover display a canvas containing the QR code for the event
        $('<canvas width=200 height=200/>').qrcode({text: "#{window.location.origin}/join/#{@joinCode}"})
    })
