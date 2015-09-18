$ ->
  $(document).on 'click', '[data-fakelink-href]', (e) ->
    $link = $(e.target).parents().andSelf().filter('[data-fakelink-href]:first')
    window.location = $link.data('fakelink-href')