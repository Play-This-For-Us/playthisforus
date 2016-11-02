class App.Song
  # song - an object representing a song object (matches song.rb)
  # songChanged - a callback function to update UI when a song is changed
  # upvote - a callback function called when the song is upvoted
  # downvote - a callback function called when the song is downvoted
  constructor: (@song, @songChanged, @upvote, @downvote) ->
    $(document).on 'click', "#songs-list__song--#{@id()} .songs-list__vote--upvote",
      (e) =>
        @upvote(@id())
        e.stopImmediatePropagation()
    $(document).on 'click', "#songs-list__song--#{@id()} .songs-list__vote--downvote",
      (e) =>
        @downvote(@id())
        e.stopImmediatePropagation()

  data: =>
    @song

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
    return ms_to_human(@song.duration)

  isHigherRanked: (song) =>
    @score() > song.score()

  scoreClass: =>
    scoreClass = 'songs-list__score'
    scoreClass += ' songs-list__score--positive' if @score() > 0
    scoreClass += ' songs-list__score--negative' if @score() < 0
    return scoreClass

  showVote: => 
    if @song.i_upvoted
      $('#fa fa-chevron-down').color('color', red)

  @spotifyResultToSong: (data) ->
    song =
      name: data.name
      artist: data.artists[0].name
      duration: data.duration_ms
      uri: data.uri
      art: data.album.images.pop().url

    return new @ song

  resultToHtml: =>
    """
    <div class='search-results__song'>
      <img class='search-results__song-art' src='#{@art()}'>
      <div class='search-results__song-description'>
        <h4 class='search-results__song-name'>
          #{@name()}
        </h4>
        <span class='search-results__song-details'>
          <i class="fa fa-microphone"></i> #{@artist()}
        </span>
        <span class='search-results__song-details'>
          <i class="fa fa-clock-o"></i> #{@duration()}
        </span>
      </div>
    </div>
    """

  toCurrentlyPlayingHtml: (time_remaining) =>
    """
      <span class="media-left">
        <img class='media-object currently-playing__avatar' src='#{@art()}' alt='Song Art'>
      </span>
      <div class="media-body">
        <a href='#{@spotifyOpenURL()}' style='text-decoration: none' target='_blank'>
          <h4 class='media-heading currently-playing__header'>
            #{@name()}
          </h4>
        </a>
        <span class='currently-playing__details'>
          <i class="fa fa-microphone"></i> #{@artist()}
        </span>
        <span class='currently-playing__details'>
          <i class="fa fa-clock-o"></i> <span id="currently-playing__remaining">#{ms_to_human(time_remaining)}</span>
        </span>
      </div>
    """

  toHtml: =>
    """
    <div class='media songs-list__song' id='songs-list__song--#{@id()}'>
      <span class='media-left'>
        <a href='#{@spotifyOpenURL()}' style='text-decoration: none' target='_blank'>
          <img class='media-object songs-list__song-avatar' src='#{@art()}' alt='Generic placeholder image'>
        </a>
      </span>
      <div class='media-body'>
        <a href='#{@spotifyOpenURL()}' style='text-decoration: none' target='_blank'>
          <h4 class='media-heading songs-list__song-title'>
            #{@name()}
          </h4>
        </a>
        <span class='songs-list__song-details'>
          <i class="fa fa-microphone"></i> #{@artist()}
        </span>
        <span class='songs-list__song-details'>
          <i class="fa fa-clock-o"></i> #{@duration()}
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
