window.hc = window.hc or {}
((pages, $) ->  
  
  pages.initS2 = ->
    $(".select2").select2()
    $(".select2-without-search").select2 minimumResultsForSearch: -1

) window.hc.pages = window.hc.pages or {}, jQuery