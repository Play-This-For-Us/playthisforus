class App.Search
  # eventChannel: EventChannel object to communicate with the backend
  # searchSelector: string to select the search element in the DOM
  # resultSelector: string to select the result element in the DOM
  # closeSelector: string to select the close element in the DOM
  constructor: (@eventChannel, @searchSelector, @resultSelector, @closeSelector) ->
    # convert the DOM selection string into a jQuery selector
    @searchSelector = $(@searchSelector)
    @resultSelector = $(@resultSelector)

    # when the user interacts with the search input
    @searchSelector.keyup @handleSearch
    $(document).on 'click', @closeSelector, @reset

  handleSearch: (e) =>
    # if the search box is empty, clear the results
    if e.currentTarget.value.length == 0
      @clearSearchResults()
      return

    @updateSearch(e.currentTarget.value)

  reset: =>
    @clearSearchInput()
    @clearSearchResults()

  clearSearchInput: =>
    @searchSelector.val("")

  clearSearchResults: =>
    @resultSelector.empty()

  updateSearch: (s) =>
    query = s
    if not query.include? '-'  # Spotify limitation
      query = query + '*' # Add a wildcard to end

    data =
      q: query
      type: 'track'
      market: 'US'
      limit: 5

    $.get('https://api.spotify.com/v1/search', data, ((data, status, jqXHR) =>
      @clearSearchResults()
      @addSearchResultEntry entry for entry in data.tracks.items
    ), 'json')

  # Add a spotify song to the search results
  addSearchResultEntry: (entry) =>
    song = App.Song.spotifyResultToSong(entry)

    entryEl = $('<span>', {
      click: =>
        @eventChannel.submitSong(song.data())
        @reset()
    })

    entryEl.append(song.resultToHtml())
    @resultSelector.append(entryEl)
