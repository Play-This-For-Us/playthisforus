class App.Song
  constructor: (@song) ->

  id: =>
    @song.id

  art: =>
    @song.art

  artist: =>
    @song.artist

  name: =>
    @song.name

  score: =>
    @song.score

  spotifyOpenURL: =>
    "http://open.spotify.com/track/#{@song.uri.replace('spotify:track:', '')}"

  duration: =>
    # convert a count of milliseconds into a human-readable duration in M:SS form
    msCount = @song.duration
    ms = msCount % 1000
    msCount = (msCount - ms) / 1000
    secs = msCount % 60
    msCount = (msCount - secs) / 60
    mins = msCount % 60

    secs = ("0" + secs).slice(-2)

    return "#{mins}:#{secs}"
