class App.Playlist
  # playlistSelector: string to select the playlist element in the DOM
  constructor: (@playlistSelector) ->
    # songs that are in the playlist
    @playlistSongs = []

    # Maximum length of the song and artist strings displayed on the search
    @maxSongLength = 50
    @maxArtistLength = 50

    # Whether we're waiting between searches
    @waitingBetweenRequests = false

    # ID of the playlist we're listening to
    # TODO(skovy) use a pass to js helper with a meta tag
    @playlistID = window.location.href.substr(window.location.href.lastIndexOf('/') + 1)

    @playlistChannel = @generatePlaylistChannel();

    @playlistSelector = $(@playlistSelector);

  # setup the channel to subscribe to event changes
  generatePlaylistChannel: =>
    App.cable.subscriptions.create { channel: "EventChannel", id: @playlistID },
      received: (data) =>
        @addSong(data)

  # add a song to the playlist data structure
  addSong: (data) =>
    song = new App.Song(data)
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
      if @playlistSongs[i].id == song.id()
        console.log i
        return i
    return -1

  # add a song view to the DOM
  appendSongUI: (song) =>

    scoreClass = "songs-list__score"
    scoreClass += " songs-list__score--positive" if song.score > 0
    scoreClass += " songs-list__score--negative" if song.score < 0

    @playlistSelector.append(
      """
      <div class='media songs-list__song'>
        <span class='media-left'>
          <img class='media-object songs-list__song-avatar' src='#{song.art()}' alt='Generic placeholder image'>
        </span>
        <div class='media-body'>
          <h4 class='media-heading songs-list__song-title'>
            #{song.name()}
          </h4>
          <span class='songs-list__song-details'>
            <i class="fa fa-microphone"></i> #{song.artist()}
          </span>
          <span class='songs-list__song-details'>
            <i class="fa fa-clock-o"></i> #{song.duration()}
          </span>
          <span class='songs-list__song-details'>
            <a href='#{song.spotifyOpenURL()}' target='_blank'>
              <i class="fa fa-spotify"></i> Open in Spotify
            </a>
          </span>
        </div>
        <span class='media-right songs-list__vote-container'>
          <button class='songs-list__vote songs-list__vote--upvote' data-song-id='#{song.id()}'>
            <i class='fa fa-chevron-up'></i>
          </button>
          <span class='songs-list__score' id='songs-list__score--#{song.id()}'>
            #{song.score()}
          </span>
          <button class='songs-list__vote songs-list__vote--downvote' data-song-id='#{song.id()}'>
            <i class='fa fa-chevron-down'></i>
          </button>
        </span>
      </div>
      """
    )

  # clear the DOM and remove the playlist
  clearPlaylistUI: =>
    @playlistSelector.empty()

  # sort the playlist based on votes and other metadata
  sortPlaylistSongs: ->
    @playlistSongs.sort (a, b) ->
      b.points - a.points

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

  # vote casting listener
  $(document).on 'click', '.songs-list__song .songs-list__vote', (e) ->
    songId = $(this).data('song-id')
    scoreSelector = $('#songs-list__score--' + songId)
    currentValue = parseInt(scoreSelector.text())
    vote = 0

    if $(this).hasClass('songs-list__vote--upvote')
      # TODO(skovy) call upvote function to persist to database
      vote = 1
    else if $(this).hasClass('songs-list__vote--downvote')
      # TODO(skovy) call downvote function to persist to database
      vote = -1

    # calculate and set new vote value
    newValue = currentValue + vote
    scoreSelector.html(newValue)

    # remove class flags
    scoreSelector.removeClass('songs-list__score--negative')
    scoreSelector.removeClass('songs-list__score--positive')

    # set the current class flag if not zero votes
    if newValue > 0
      scoreSelector.addClass('songs-list__score--positive')
    else if newValue < 0
      scoreSelector.addClass('songs-list__score--negative')
  )
