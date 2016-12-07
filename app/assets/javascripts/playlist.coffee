class App.Playlist
  # playlistSelector: string to select the playlist element in the DOM
  constructor: (@playlistSelector) ->
    # convert the DOM selection string into a jQuery selector
    @playlistSelector = $(@playlistSelector)

    @playlistSongs = [] # songs that are in the playlist

    @playlistChannel = new App.EventChannel(@pushSong, @removeSong, @updateCurrentSong, @clearSongs)

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

  clearSongs: =>
    @playlistSongs = []
    @updatePlaylistUI()

  # add a song to the playlist data structure
  pushSong: (data) =>
    songPosition = @findSong(data)

    if songPosition >= 0
      # update the existing song
      @playlistSongs[songPosition].updateSong(data)
    else
      # append to the end of the songs
      @playlistSongs.push(new App.Song(data, @updatePlaylistUI, @sendUpvote, @sendDownvote, @sendSuperVote))

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
    @playlistSongs = @playlistSongs.sort (a, b) ->
      if a.superVote() && !b.superVote()
        # a is super voted and b is not, a goes first
        return -1
      else if !a.superVote() && b.superVote()
        # b is super voted and a is not, b goes first
        return 1

      # If supervotes are a tie (eg: both true or both false) use vote scores
      if a.score() == b.score()
        # Tie on score, sort by time submitted
        bQueueSecs = Date.parse(b.song.created_at)
        aQueueSecs = Date.parse(a.song.created_at)

        if aQueueSecs > bQueueSecs  # B queued first
          return 1
        else if aQueueSecs < bQueueSecs  # A queued first
          return -1
        else  # There was a tie
          return b.id() - a.id()  # If B's ID is greater, put A first
      else
        # Score didn't tie
        return b.score() - a.score()

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

  # send a supervote to the server (either to add or remove)
  sendSuperVote: (songID) =>
    @playlistChannel.superVote(songID)

  pnator: =>
    @playlistChannel.pnator()

  starSong: (songID) =>
    @playlistChannel.saveSong(songID)
