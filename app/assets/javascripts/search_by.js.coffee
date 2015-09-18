$search_by = $('.search-by')
$('#query').on 'focus', ->
  $search_by.show()
  $('.posts-search .search-btn').css
    visibility: 'hidden'

$('.search-by input, #query').on 'focus', ->
  $('.search-by input, #query').not(@).not('[type="hidden"]').val '' unless $search_by.hasClass('fresh')
  $search_by.removeClass 'fresh'

$('.posts-search .search-btn').on 'click', ->
  if $('#query').val() is ''
    $search_by.find('form').trigger 'submit'
  else
    $(@).closest('form').trigger 'submit'

$('.search-by input, #query').on 'change', -> 
  if !$search_by.is(':visible')
    val = $('.search-by input, #query').val().replace(/\(\d+\)/, '').trim()
    $('.search-by input, #query').val(val)

$search_by.find('.search-btn').on 'click', ->
  $search_by.closest('.spacing-search').find('.posts-search').trigger 'submit'

$(document).on 'click', (e) ->
  query_input = $('#query')
  if !$search_by.is(e.target) && !$(e.target).parent().hasClass('tag') && !query_input.is(e.target) && $search_by.has(e.target).length == 0
    $search_by.hide()
    $('.posts-search .search-btn').css
      visibility: 'visible'

confirmKeys = [13, 9, 188]
$('#desease_tag_search').tagsinput
  confirmKeys: confirmKeys
  typeahead:
    source: (query) ->
      $.get('/conditions/autocomplete.json', { query: query })

$('.search-by').on 'keypress', 'input', (e) ->
  $search_by.find('form').trigger 'submit' if e.keyCode is 13

$search_by.find("#by_member_search").typeahead source: (query, process) ->
  $.get "/users/autocomplete.json",
    query: query
  , (data) ->
    process data.options

$search_by.find('form').on 'submit', ->
  e = jQuery.Event 'keydown'
  e.which = 13
  $(@).find('.bootstrap-tagsinput input').trigger e