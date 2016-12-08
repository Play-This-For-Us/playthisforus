class App.Alert
  constructor: (@text, @type) ->

  mount: =>
    $("body").append(@toHtml())

  unmount: =>
    $(".alert--dynamic").remove()

  update: (text, type) =>
    @text = text
    @type = type

    # clear any existing timeout to hide the alert
    # happens when users perform many actions quickly
    clearTimeout(@timeout) if @timeout
    @hide() # hide the existing alert
    @mount() # show the new, updated alert

    # hide the alert in 3 seconds if the user doesn't close it manually
    @timeout = setTimeout(@hide, 3000)

  hide: =>
    if @elementID
      $("##{@elementID}").fadeOut()

  icon: =>
    if @type == 'success'
      return '<i class="fa fa-check-circle"></i>'
    else if @type == 'warning'
      return '<i class="fa fa-exclamation"></i>'
    else if @type == 'info'
      return '<i class="fa fa-info-circle"></i>'
    else if @type == 'danger'
      return '<i class="fa fa-exclamation-triangle"></i>'
    return ''

  generateID: =>
    @elementID = (new Date()).getTime()
    return @elementID

  toHtml: =>
    """
    <div class="alert__container--fixed alert--dynamic" id="#{@generateID()}">
      <div class="alert alert-#{@type} flash-display alert--fixed">
        <a class="close" data-dismiss="alert">
          <i class="fa fa-times"></i>
        </a>
        #{@icon()}
        #{@text}
      </div>
    </div>
    """
