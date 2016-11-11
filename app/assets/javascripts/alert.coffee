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

  icon: =>
    if @type == 'success'
      return '<i class="fa fa-check-circle"></i>'
    else if @type == 'danger'
      return '<i class="fa fa-exclamation-triangle"></i>'
    else if @type == 'info'
      return '<i class="fa fa-info-circle"></i>'

  toHtml: =>
    """
    <div class="alert__container--fixed alert--dynamic">
      <div class="alert alert-#{@type} flash-display alert--fixed">
        <a class="close" data-dismiss="alert">
          <i class="fa fa-times"></i>
        </a>
        #{@icon()}
        #{@text}
      </div>
    </div>
    """
