class App.CurrentSong extends App.Song
  constructor: (@song, @songChanged, @upvote, @downvote) ->
    super(@song, @songChanged, @upvote, @downVote)

  updateTimeRemainingView: =>
    $('#currently-playing__remaining').html(ms_to_human(@timeRemainingMS()))

  timeRemainingMS: =>
    @song.time_remaining

  toCurrentlyPlayingHtml: =>
    html = """
      <span class="media-left">
        <img class='media-object currently-playing__avatar' src='#{@art()}' alt='Song Art'>
      </span>
      <div class="media-body">
        <a href='#{@spotifyOpenURL()}' style='text-decoration: none' target='_blank'>
          <h4 class='media-heading currently-playing__header'>
            #{@name()}
    """

    # Put star button if user is authed with Spotify
    if user_spotify_authed
      html += """
      <a class="btn" id="currently-playing__star" target="#"><i class="fa fa-star-o" aria-hidden="true"></i></a>
      """

    html += """
          </h4>
        </a>
        <span class='currently-playing__details'>
          <i class="fa fa-microphone"></i> #{@artist()}
        </span>
        <span class='currently-playing__details'>
          <i class="fa fa-clock-o"></i> <span id="currently-playing__remaining">#{ms_to_human(@timeRemainingMS())}</span>
        </span>
      </div>
    """
