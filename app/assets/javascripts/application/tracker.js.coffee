# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $('.remove-tracker-help').on 'click', ->
    $(@).closest('.how-it-works').fadeOut(->
      $('.overall-title').removeClass 'with-video'
    )
    $.cookie 'hide_tracker_video', '1', {path: '/'}