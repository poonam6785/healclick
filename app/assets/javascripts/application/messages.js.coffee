$ ->
  $(".message.clickable").click ->
    message_id = $(this).attr("id").replace("message_", "")
    window.location.href = "/messages/" + message_id
    return

  $(".user_full_name").typeahead source: (query, process) ->
    $.get "/users/autocomplete.json",
      query: query
    , (data) ->
      process data.options

  if $('#dialog-box').length is 1
    $('#dialog-box').scrollTo($('#dialog-box')[0].scrollHeight)
    message_id = $(@).find('.message:last').data 'id'
    $('#dialog-box').on 'scroll', ->
      if $(@).scrollTop() is 0
        next_page = $('#paginate-messages li.current').next().find('a').text()
        if next_page
          $.ajax
            url: "/messages/#{message_id}"
            data: 
              page: next_page
            dataType: 'script'