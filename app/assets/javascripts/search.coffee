class App.Search
  # searchSelector: string to select the search element in the DOM
  # playlistView: a Playlist class to interact with
  constructor: (@searchSelector, @playlistView) ->
    # convert the DOM selection string into a jQuery selector
    @searchSelector = $(@searchSelector);

    $("#songSearchEntry").keyup((e) => # When the user changes what is in the search box
      # If the search box is empty, clear the results
      if e.currentTarget.value.length == 0
        $('.search-results').empty()
        return

      if(@playlistView.waitingBetweenRequests) # Wait a bit between requests
        setTimeout((=> @updateSearch(e.currentTarget.value)), 1010)
      else
        @updateSearch(e.currentTarget.value)

        # wait 500 ms between requests
        @playlistView.waitingBetweenRequests = true
        setTimeout((=> @playlistView.waitingBetweenRequests = false), 1000)
    )

  updateSearch: (s) =>
    data =
      q: s
      type: 'track'
      market: 'US'
      limit: 5

    $.get('https://api.spotify.com/v1/search', data, ((data, status, jqXHR) =>
      $(".search-results").empty()
      @addSearchResultEntry entry for entry in data.tracks.items
    ), 'json')


  onSearchResultClick: (e) =>
    e.preventDefault()
    @playlistView.send(jQuery.data(e.currentTarget, 'song'))

  # Add a spotify song to the search results
  addSearchResultEntry: (entry) =>
    songTitle = entry.name
    artistName = entry.artists[0].name

    if songTitle.length > @maxSongLength
      songTitle = songTitle.substring(0, @maxSongLength - 3) + '...'

    if artistName.length > @maxArtistLength
      artistName = artistName.substring(0, @maxArtistLength - 3) + '...'

    imageURL = entry.album.images.pop().url

    entryEl = $('<a>', {
      href: '#',
      click: @onSearchResultClick
    })

    playthisSong =
      name: entry.name
      artist: entry.artists[0].name
      duration: entry.duration_ms
      uri: entry.uri
      art: imageURL

    entryEl.data('song', playthisSong)

    searchResultHTML =
      "<div class=\"row search-result clearfix\"><div class=\"col-md-12\">" +
        "<img class=\"search-result-art\" src=\"#{imageURL}\">" +
        "<a class=\"search-result-text\"> " +
        "<p class=\"search-result-title\">#{songTitle}</p>" +
        "<p class=\"search-result-artist\">#{artistName}</p>" +
        "</a></div></div>"

    entryEl.append(searchResultHTML)

    $(".search-results").append(entryEl)
