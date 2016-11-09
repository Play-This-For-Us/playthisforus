# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file. JavaScript code in this file should be added after the last require_* statement.
#
# Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
# about supported directives.
#
#= require jquery
#= require jquery_ujs
#= require tether
#= require bootstrap
#= require jquery-qrcode
#= require bootstrap-slider
#
# Enforce order for class hierarchy
#= require cable
#= require song
#= require current_song
#= require_tree .

root = exports ? this

root.ms_to_human = (msCount) ->
  # convert a count of milliseconds into a human-readable duration in M:SS form
  ms = msCount % 1000
  msCount = (msCount - ms) / 1000
  secs = msCount % 60
  msCount = (msCount - secs) / 60
  mins = msCount % 60

  secs = ("0" + secs).slice(-2)

  return "#{mins}:#{secs}"

# When the document is rendered, setup our DOM manipulations
$(document).ready ->
  eventView = new App.EventCreateForm('#pnatorToggle', '#pnatorFields')
  eventView = new App.Event('#eventQRPopover', '#eventJoinCode')
  playlistView = new App.Playlist('.songs-list')
  searchView = new App.Search(playlistView.getEventChannel(), '.search-entry', '.search-results', '.search-results__close')
