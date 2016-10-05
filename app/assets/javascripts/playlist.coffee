# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

MAX_SONG_LEN = 50
MAX_ARTIST_LEN = 50

playlistSongs = []

waitingBetweenRequests = false

$(document).ready(=>
  $("#songSearchEntry").keyup((e) ->
    if e.currentTarget.value.length == 0
      $('#search-results').empty()
      return

    if(waitingBetweenRequests)
      setTimeout((=> updateSearch(e.currentTarget.value)), 1010)
    else
      updateSearch(e.currentTarget.value)

      # wait 500 ms between requests
      waitingBetweenRequests = true
      setTimeout((=> waitingBetweenRequests = false), 1000)
  )

  addPlaceholderSongs()
  updateSongListView()
)

addPlaceholderSongs = =>
  contact =
    id: 0
    title: 'Contact'
    artist: 'Daft Punk'
    duration: '6:24'
    points: '5'
    active: true

  randy =
    id: 1
    title: 'Randy'
    artist: 'Justice'
    duration: '3:13'
    points: '3'
    active: false

  nggyu =
    id: 2
    title: 'Never Gonna Give You Up'
    artist: 'Rick Astley'
    duration: '3:33'
    points: '-2'
    active: false

  addSong(contact)
  addSong(randy)
  addSong(nggyu)

addSong = (song) ->
  playlistSongs.push(song)

appendSongView = (song) ->
  $("#songsTableBody").append("<tr>" +
      "<td>#{song.title}</td>" +
      "<td>#{song.artist}</td>" +
      "<td>#{song.duration}</td>" +
      "<td>#{song.points}</td>" +
      "</tr>")

updateSongListView = =>
  # Sort the songs by upvotes
  playlistSongs.sort (a, b) ->
    b.points - a.points

  # Clear the table
  $("#songsTableBody").empty()

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

addSearchResultEntry = (entry) ->
  songTitle = entry.name
  artistName = entry.artists[0].name

  if songTitle.length > MAX_SONG_LEN
    songTitle = songTitle.substring(0, MAX_SONG_LEN - 3) + '...'

  if artistName.length > MAX_ARTIST_LEN
    artistName = artistName.substring(0, MAX_ARTIST_LEN - 3) + '...'

  imageURL = entry.album.images.pop().url

  searchResultHTML =
    "<div class=\"row search-result clearfix\"><div class=\"col-md-12\">" +
      "<img class=\"search-result-art\" src=\"#{imageURL}\">" +
      "<a class=\"search-result-text\"> " +
      "<p class=\"search-result-title\">#{songTitle}</p>" +
      "<p class=\"search-result-artist\">#{artistName}</p>" +
      "</a></div></div>"

  $("#search-results").append(searchResultHTML)