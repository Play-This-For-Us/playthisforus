class App.Search
  # searchSelector: string to select the search element in the DOM
  # resultSelector: string to select the result element in the DOM
  constructor: (@searchSelector, @resultSelector) ->
    # convert the DOM selection string into a jQuery selector
    @searchSelector = $(@searchSelector);
    @resultSelector = $(@resultSelector);

    # when the user interacts with the search input
    @searchSelector.keyup @handleSearch

    @waitingBetweenRequests = false
    @playlistID = window.location.href.substr(window.location.href.lastIndexOf('/') + 1)
    @eventChannel = @generateEventChannel()


  # setup the channel to subscribe to event changes
  generateEventChannel: =>
    App.cable.subscriptions.create { channel: "EventChannel", id: @playlistID }

  # send data over the channel
  send: (data) =>
    console.log data
    @eventChannel.send(data)

  handleSearch: (e) =>
    # if the search box is empty, clear the results
    if e.currentTarget.value.length == 0
      @clearSearchResults()
      return

    if @waitingBetweenRequests # wait a bit between requests
      setTimeout((=> @updateSearch(e.currentTarget.value)), 1010)
    else
      @updateSearch(e.currentTarget.value)

      # wait 500 ms between requests
      @waitingBetweenRequests = true
      setTimeout((=> @waitingBetweenRequests = false), 1000)

  clearSearchResults: =>
    @resultSelector.empty()

  updateSearch: (s) =>
    data =
      q: s
      type: 'track'
      market: 'US'
      limit: 5

    $.get('https://api.spotify.com/v1/search', data, ((data, status, jqXHR) =>
      @clearSearchResults()
      @addSearchResultEntry entry for entry in data.tracks.items
    ), 'json')

  # Add a spotify song to the search results
  addSearchResultEntry: (entry) =>
    song = App.Song.spotifyResultToSong(entry);

    entryEl = $('<span>', {
      click: => @send(song.data())
    })

    entryEl.append(song.resultToHtml())
    @resultSelector.append(entryEl)
