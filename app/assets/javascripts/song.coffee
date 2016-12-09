class App.Song
  # song - an object representing a song object (matches song.rb)
  # songChanged - a callback function to update UI when a song is changed
  # upvote - a callback function called when the song is upvoted
  # downvote - a callback function called when the song is downvoted
  constructor: (@song, @songChanged, @upvote, @downvote, @super) ->
    @currentUserIsOwner = window.currentUserIsOwner
    $(document).on 'click', "#songs-list__song--#{@id()} .songs-list__vote--upvote",
      (e) =>
        @upvote(@id())
        e.stopImmediatePropagation()
    $(document).on 'click', "#songs-list__song--#{@id()} .songs-list__vote--downvote",
      (e) =>
        @downvote(@id())
        e.stopImmediatePropagation()
    $(document).on 'click', "#songs-list__song--#{@id()} .songs-list__super-vote-button",
      (e) =>
        @super(@id())
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

  superVote: =>
    @song.super_vote

  score: =>
    parseInt(@song.score)

  # updates an already existent song in the UI - only update attributes that
  # should be updated in the UI
  updateSong: (song) =>
    return unless song

    @song.score = parseInt(song.score)
    @song.super_vote = song.super_vote

    # only update the current user's vote if it exists on the updated song
    if song.hasOwnProperty('current_user_vote')
      @song.current_user_vote = song.current_user_vote

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

  upvoteClass: =>
    if @song.current_user_vote && @song.current_user_vote > 0
     return "vote--upvoted"

  downvoteClass: =>
    if @song.current_user_vote && @song.current_user_vote < 0
      return "vote--downvoted"

  @spotifyResultToSong: (data) ->
    song =
      name: data.name
      artist: data.artists[0].name
      duration: data.duration_ms
      uri: data.uri
      art: data.album.images.pop().url

    return new @ song

  superVoteClass: =>
    # this is just visual, all users (inlcuding guests) need to see the super
    # vote status
    if @superVote()
      "songs-list__song-super-vote"
    else
      ""

  superVoteHtml: =>
    # this is just visual, all users (inlcuding guests) need to see the super
    # vote status
    if @superVote()
      """
        <div class="songs-list__super-vote">
          <i class="fa fa-rocket"></i>
          Super Upvoted by Host
        </div>
      """
    else
      ""

  superVoteButton: =>
    # we only want to display the button to super upvote to the event owner
    # at the time, if there is an issue we will also authenticate serverside
    return "" unless @currentUserIsOwner

    text = "Super Vote"
    if @superVote()
      text = "Remove Super Vote"

    """
      <a href="#" class='songs-list__super-vote-button'>
        <i class='fa fa-rocket'></i>
        #{text}
      </a>
    """

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

  toHtml: =>
    """
    <div class='#{@superVoteClass()} songs-list__container' id='songs-list__song--#{@id()}'>
      <div class='media songs-list__song'>
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
          #{@superVoteButton()}
        </div>
        <span class='media-right songs-list__vote-container'>
          <button class='songs-list__vote songs-list__vote--upvote #{@upvoteClass()}'>
            <i class='fa fa-chevron-up'></i>
          </button>
          <span class='#{@scoreClass()}'>
            #{@score()}
          </span>
          <button class='songs-list__vote songs-list__vote--downvote #{@downvoteClass()}'>
            <i class='fa fa-chevron-down'></i>
          </button>
        </span>
      </div>
      #{@superVoteHtml()}
    </div>
    """
