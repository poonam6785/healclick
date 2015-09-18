$ ->
  $(document).on 'loading:start', (e) ->
    unless $('#loading').data('disabled')
      $('#loading').show()
      window.onbeforeunload = -> 'Your changes are being saved, are you sure you want to leave the page?'
  $(document).on 'loading:stop', (e) ->
    $('#loading').hide()
    window.onbeforeunload = null

  $(document).ajaxSend (e, xhr, settings) ->
    regex = new RegExp(/(notifications)|(autocomplete)|(symptoms_chart)/)
    unless regex.test settings.url
      $(document).trigger('loading:start')
  $(document).ajaxComplete (e, xhr, settings) ->
    regex = new RegExp(/(notifications)|(autocomplete)|(symptoms_chart)/)
    unless regex.test settings.url
      $(document).trigger('loading:stop')