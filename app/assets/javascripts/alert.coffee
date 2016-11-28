class App.Alert
  constructor: (@text, @type) ->

  mount: =>
    $("body").append(@toHtml())

  unmount: =>
    $(".alert--dynamic").remove()

  update: (text, type) =>
    @text = text
    @type = type
    @unmount()
    @mount()
    setTimeout(@hide, 3000)

  hide: =>
    if @elementID
      $("##{@elementID}").fadeOut()

  icon: =>
    if @type == 'success'
      return '<i class="fa fa-check-circle"></i>'
    else if @type == 'warning'
      return '<i class="fa fa-exclamation-triangle"></i>'
    else if @type == 'info'
      return '<i class="fa fa-info-circle"></i>'

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
