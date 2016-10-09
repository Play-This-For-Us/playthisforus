class App.Playlist
  # playlistSelector: string to select the playlist element in the DOM
  constructor: (@playlistSelector) ->
    # convert the DOM selection string into a jQuery selector
    @playlistSelector = $(@playlistSelector);

    @playlistSongs = [] # songs that are in the playlist

    # ID of the playlist we're listening to
    # TODO(skovy) use a pass to js helper with a meta tag
    @playlistID = window.location.href.substr(window.location.href.lastIndexOf('/') + 1)

    @playlistChannel = new App.EventChannel(@addSong);

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

# When the document is rendered, setup our DOM manipulations
$(document).ready ->
  playlistView = new App.Playlist(".songs-list")
  searchView = new App.Search(".search-entry", ".search-results", ".search-results__close")
