$ ->
  $(document).one 'click', '.treatments .btn.datepicker', (e) ->
    $target = $(@)
    tomorrow = new Date()
    tomorrow.setDate(tomorrow.getDate() + 1)
    datepicker = $target.datepicker
      endDate: tomorrow

    datepicker.on 'changeDate', (e) ->
      date = $.format.date(e.date, "yyyy-MM-dd")
      $('.treatments .tracking-date .date').html $.format.date(e.date, "MMM d")
      $('input#tracking_date').val date
      $.getScript("/tracker/treatments.js?date=#{date}")
    datepicker.on 'show', (e) ->
      if $target.hasClass 'open'
        $target.datepicker 'hide'
      else
        $target.addClass 'open'
    datepicker.on 'hide', (e) ->
      $target.removeClass 'open'
    $target.datepicker 'show'
    false

  $(document).one 'click', '.labs .btn.datepicker', (e) ->
    $target = $(@)
    tomorrow = new Date()
    tomorrow.setDate(tomorrow.getDate() + 1)
    datepicker = $target.datepicker
      endDate: tomorrow
    datepicker.on 'changeDate', (e) ->
      date = $.format.date(e.date, "yyyy-MM-dd")
      $.getScript("/labs/change_date.js?date=#{date}")
    datepicker.on 'show', (e) ->
      if $target.hasClass 'open'
        $target.datepicker 'hide'
      else
        $target.addClass 'open'
    datepicker.on 'hide', (e) ->
      $target.removeClass 'open'
    $target.datepicker 'show'
    false

  $(document).on 'click', '.treatments .btn.datepicker, .labs .btn.datepicker', (e) ->
    false

  $(document).on 'click', '.events .btn.datepicker', (e) ->
    $target = $ e.currentTarget
    unless $target.data 'datepicker'
      tomorrow = new Date()
      tomorrow.setDate(tomorrow.getDate() + 1)
      datepicker = $target.datepicker
        endDate: tomorrow

      datepicker.on 'changeDate', (e) ->
        date = $.format.date(e.date, "yyyy-MM-dd")
        $('.events .tracking-date .date').html $.format.date(e.date, "MMM d")
        $('.events input#event_date').val date

        $target.datepicker('hide')
        false

      datepicker.on 'hide', (e) ->
        $target.datepicker('remove')

    if $('.datepicker-dropdown').is(':visible')
      $target.datepicker('hide')
    else
      $target.datepicker('show')