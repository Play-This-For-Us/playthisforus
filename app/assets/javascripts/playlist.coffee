# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# Maximum length of the song and artist strings displayed on the search
MAX_SONG_LEN = 50
MAX_ARTIST_LEN = 50

# Songs that are in the playlist
playlistSongs = []

# Whether we're waiting between searches
waitingBetweenRequests = false

# ID of the playlist we're listening to
playlistID = window.location.href.substr(window.location.href.lastIndexOf('/') + 1)


# Subscribe to the action cable channel
App.playlistChannel = App.cable.subscriptions.create { channel: "EventChannel", id: playlistID },
  received: (data) ->
    addSong(data)
    updateSongListView()


# When the document is rendered, setup our DOM manipulations
$(document).ready(->
  $("#songSearchEntry").keyup((e) -> # When the user changes what is in the search box
    # If the search box is empty, clear the results
    if e.currentTarget.value.length == 0
      $('#search-results').empty()
      return

    if(waitingBetweenRequests) # Wait a bit between requests
      setTimeout((-> updateSearch(e.currentTarget.value)), 1010)
    else
      updateSearch(e.currentTarget.value)

      # wait 500 ms between requests
      waitingBetweenRequests = true
      setTimeout((-> waitingBetweenRequests = false), 1000)
  )
)


# Add a song to the playlist data structure
addSong = (song) ->
  # if the song already exist, replace
  existed = false
  for i in [0 ... playlistSongs.length]
    if playlistSongs[i].uri == song.uri
      playlistSongs[i] = song
      existed = true
      break

  if(!existed)
    playlistSongs.push(song)


# Add a song view to the DOM
appendSongView = (song) ->
  songDuration = msToTime(song.duration)
  console.log(song)
  # $(".songs-list").append("<tr>" +
  #     "<td>#{song.name}</td>" +
  #     "<td>#{song.artist}</td>" +
  #     "<td>#{songDuration}</td>" +
  #     "<td>#{song.score}</td>" +
  #     "</tr>")
  $(".songs-list").append(
    """
    <div class='media songs-list__song'>
      <span class='media-left'>
        <img class='media-object songs-list__song-avatar' src='#{song.art}' alt='Generic placeholder image'>
      </span>
      <div class='media-body'>
        <h4 class='media-heading songs-list__song-title'>
          #{song.name}
          <small class='pull-xs-right songs-list__song-subtitle'>
            <a href='http://open.spotify.com/track/#{song.uri.replace('spotify:track:', '')}' target='_blank'>
              <i class="fa fa-spotify"></i> Open in Spotify
            </a>
          </small>
        </h4>
        <span class='songs-list__song-details'>
          <i class="fa fa-microphone"></i> #{song.artist}
        </span>
        <span class='songs-list__song-details'>
          <i class="fa fa-clock-o"></i> #{songDuration}
        </span>
      </div>
    </div>
    """
  )

# Update the playlist view with the contents of our song list
updateSongListView = ->
  # Sort the songs by upvotes
  playlistSongs.sort (a, b) ->
    b.points - a.points

  # Clear the table
  $(".songs-list").empty()

  # Add each song to the table
  appendSongView(song) for song in playlistSongs


updateSearch = (s) ->
  data =
    q: s
    type: 'track'
    market: 'US'
    limit: 5

  $.get('https://api.spotify.com/v1/search', data, ((data, status, jqXHR) ->
    $("#search-results").empty()
    addSearchResultEntry entry for entry in data.tracks.items
  ), 'json')


onSearchResultClick = (event) ->
  App.playlistChannel.send(jQuery.data(event.currentTarget, 'song'))
  event.preventDefault()


# Add a spotify song to the search results
addSearchResultEntry = (entry) ->
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


# Convert a count of milliseconds into a human-readable duration in M:SS form
msToTime = (msCount) ->
  ms = msCount % 1000
  msCount = (msCount - ms) / 1000
  secs = msCount % 60
  msCount = (msCount - secs) / 60
  mins = msCount % 60

  secs = ("0" + secs).slice(-2)

  return "#{mins}:#{secs}"
