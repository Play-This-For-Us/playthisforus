class App.Playlist
  # playlistSelector: string to select the playlist element in the DOM
  constructor: (@playlistSelector) ->
    # convert the DOM selection string into a jQuery selector
    @playlistSelector = $(@playlistSelector)

    @playlistSongs = [] # songs that are in the playlist

    @playlistChannel = new App.EventChannel(@pushSong, @removeSong, @updateCurrentSong)

    window.onhashchange = =>
      if location.hash == '#pnator'
        @pnator()
        location.hash = '#' # reset back so that onhashchange will be called again

    $(document).on 'click', '#currently-playing__star',
      (e) =>
        e.stopImmediatePropagation()
        if(!@currentPlaying.saved)
          @starSong(@currentPlaying.id())
          @currentPlaying.markSaved()

    # Update the time remaining every second
    setInterval(
      (=>
        if(@currentPlaying)
          @currentPlaying.song.time_remaining -= 1000
          @currentPlaying.updateTimeRemainingView())
      , 1000)

  getEventChannel: =>
    @playlistChannel

  updateCurrentSong: (data) =>
    @currentPlaying = new App.CurrentSong(data)
    $('.currently-playing__song').html(@currentPlaying.toCurrentlyPlayingHtml())

  # add a song to the playlist data structure
  pushSong: (data) =>
    songPosition = @findSong(data)

    if songPosition >= 0
      # update the existing song
      @playlistSongs[songPosition].updateSong(data)
    else
      # append to the end of the songs
      @playlistSongs.push(new App.Song(data, @updatePlaylistUI, @sendUpvote, @sendDownvote))

    # update the playlsit UI
    @updatePlaylistUI()

  # remove a song from the playlsit data structure
  removeSong: (data) =>
    songPosition = @findSong(data)

    if songPosition >= 0
      @playlistSongs.splice(songPosition, 1)

      # update the playlsit UI
      @updatePlaylistUI()

  # find a song position in the playlist, returns -1 if nonexistant
  findSong: (song) =>
    for i in [0 ... @playlistSongs.length]
      return i if @playlistSongs[i].id() == song.id
    return -1

  # add a song view to the DOM
  appendSongUI: (song) =>
    @playlistSelector.append(song.toHtml())

  # clear the DOM and remove the playlist
  clearPlaylistUI: =>
    @playlistSelector.empty()

  # sort the playlist based first on score, then on time queued
  sortPlaylistSongs: ->
    @playlistSongs.sort (a, b) ->
      if a.score == b.score
        return Date.parse(b.queued_at).getUTCSeconds() - Date.parse(a.queued_at).getUTCSeconds()
      else
        return b.score - a.score

  # update the playlist view with the contents of our song list
  updatePlaylistUI: =>
    @sortPlaylistSongs()
    @clearPlaylistUI()
    @appendSongUI(song) for song in @playlistSongs

  # send an upvote to the server
  sendUpvote: (songID) =>
    @playlistChannel.vote(songID, true)

  # send a downvote to the server
  sendDownvote: (songID) =>
    @playlistChannel.vote(songID, false)

  pnator: =>
    @playlistChannel.pnator()

  starSong: (songID) =>
    @playlistChannel.saveSong(songID)
