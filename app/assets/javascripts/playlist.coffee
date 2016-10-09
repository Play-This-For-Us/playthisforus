class App.Playlist
  # playlistSelector: string to select the playlist element in the DOM
  constructor: (@playlistSelector) ->
    @playlistSongs = [] # songs that are in the playlist

    # Maximum length of the song and artist strings displayed on the search
    @maxSongLength = 50
    @maxArtistLength = 50

    # Whether we're waiting between searches
    @waitingBetweenRequests = false

    # ID of the playlist we're listening to
    # TODO(skovy) use a pass to js helper with a meta tag
    @playlistID = window.location.href.substr(window.location.href.lastIndexOf('/') + 1)

    @playlistChannel = @generatePlaylistChannel();

    # convert the DOM selection string into a jQuery selector
    @playlistSelector = $(@playlistSelector);

  # setup the channel to subscribe to event changes
  generatePlaylistChannel: =>
    App.cable.subscriptions.create { channel: "EventChannel", id: @playlistID },
      received: (data) =>
        @addSong(data)

  # add a song to the playlist data structure
  addSong: (data) =>
    song = new App.Song(data, @updatePlaylistUI)
    songPosition = @findSong(song)

    if songPosition >= 0
      # overwrite the existing song
      @playlistSongs[songPosition] = song
    else
      # append to the end of the songs
      @playlistSongs.push(song)

    # update the playlsit UI
    @updatePlaylistUI()

  # find a song position in the playlist, returns -1 if nonexistant
  findSong: (song) =>
    for i in [0 ... @playlistSongs.length]
        return i if @playlistSongs[i].isEqual(song)
    return -1

  # add a song view to the DOM
  appendSongUI: (song) =>
    @playlistSelector.append(song.toHtml())

  # clear the DOM and remove the playlist
  clearPlaylistUI: =>
    @playlistSelector.empty()

  # sort the playlist based on votes and other metadata
  sortPlaylistSongs: ->
    @playlistSongs.sort (a, b) ->
      b.score() - a.score()

  # update the playlist view with the contents of our song list
  updatePlaylistUI: =>
    @sortPlaylistSongs()
    @clearPlaylistUI()
    @appendSongUI(song) for song in @playlistSongs

  updateSearch: (s) =>
    data =
      q: s
      type: 'track'
      market: 'US'
      limit: 5

    $.get('https://api.spotify.com/v1/search', data, ((data, status, jqXHR) =>
      $("#search-results").empty()
      @addSearchResultEntry entry for entry in data.tracks.items
    ), 'json')


  onSearchResultClick: (event) =>
    @playlistChannel.send(jQuery.data(event.currentTarget, 'song'))
    event.preventDefault()

  # Add a spotify song to the search results
  addSearchResultEntry: (entry) =>
    songTitle = entry.name
    artistName = entry.artists[0].name

    if songTitle.length > MAX_SONG_LEN
      songTitle = songTitle.substring(0, MAX_SONG_LEN - 3) + '...'

    if artistName.length > MAX_ARTIST_LEN
      artistName = artistName.substring(0, MAX_ARTIST_LEN - 3) + '...'

    imageURL = entry.album.images.pop().url

    entryEl = $('<a>', {
      href: '#',
      click: onSearchResultClick
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

    $("#search-results").append(entryEl)


# When the document is rendered, setup our DOM manipulations
$(document).ready(->
  playlistView = new App.Playlist(".songs-list")

  $("#songSearchEntry").keyup((e) -> # When the user changes what is in the search box
    # If the search box is empty, clear the results
    if e.currentTarget.value.length == 0
      $('#search-results').empty()
      return

    if(playlistView.waitingBetweenRequests) # Wait a bit between requests
      setTimeout((-> playlistView.updateSearch(e.currentTarget.value)), 1010)
    else
      playlistView.updateSearch(e.currentTarget.value)

      # wait 500 ms between requests
      playlistView.waitingBetweenRequests = true
      setTimeout((-> playlistView.waitingBetweenRequests = false), 1000)
  )
)
