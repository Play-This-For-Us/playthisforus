class App.Song
  # song - an object representing a song object (matches song.rb)
  # songChanged - a callback function to update UI when a song is changed
  constructor: (@song, @songChanged) ->
    $(document).on 'click', "#songs-list__song--#{@id()} .songs-list__vote--upvote", @upvote
    $(document).on 'click', "#songs-list__song--#{@id()} .songs-list__vote--downvote", @downvote

  id: =>
    @song.id

  art: =>
    @song.art

  artist: =>
    @song.artist

  name: =>
    @song.name

  score: =>
    parseInt(@song.score)

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

  isEqual: (song) =>
    @id() == song.id()

  isHigherRanked: (song) =>
    @score() > song.score()

  upvote: =>
    # TODO(skovy): persist to the database
    @song.score += 1
    @songChanged()

  downvote: =>
    # TODO(skovy): persist to the database
    @song.score -= 1
    @songChanged()

  scoreClass: =>
    scoreClass = "songs-list__score"
    scoreClass += " songs-list__score--positive" if @score() > 0
    scoreClass += " songs-list__score--negative" if @score() < 0
    return scoreClass

  toHtml: =>
    """
    <div class='media songs-list__song' id='songs-list__song--#{@id()}'>
      <span class='media-left'>
        <img class='media-object songs-list__song-avatar' src='#{@art()}' alt='Generic placeholder image'>
      </span>
      <div class='media-body'>
        <h4 class='media-heading songs-list__song-title'>
          #{@name()}
        </h4>
        <span class='songs-list__song-details'>
          <i class="fa fa-microphone"></i> #{@artist()}
        </span>
        <span class='songs-list__song-details'>
          <i class="fa fa-clock-o"></i> #{@duration()}
        </span>
        <span class='songs-list__song-details'>
          <a href='#{@spotifyOpenURL()}' target='_blank'>
            <i class="fa fa-spotify"></i> Open in Spotify
          </a>
        </span>
      </div>
      <span class='media-right songs-list__vote-container'>
        <button class='songs-list__vote songs-list__vote--upvote'>
          <i class='fa fa-chevron-up'></i>
        </button>
        <span class='#{@scoreClass()}'>
          #{@score()}
        </span>
        <button class='songs-list__vote songs-list__vote--downvote'>
          <i class='fa fa-chevron-down'></i>
        </button>
      </span>
    </div>
    """
