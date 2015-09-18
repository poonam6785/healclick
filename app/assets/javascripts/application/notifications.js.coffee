get_notifications = ->
  $.getScript "/notifications.js"
window.get_notifications = get_notifications

$ ->
  setInterval ->
    window.get_notifications()
  , 20000

  $(document).on 'init_notifications_popover', ->
    $("#top-notifications-link").popover
      html: true
      title: $(".notifications-widget .header").html()
      content: $("#latest_notifications_container").html()
      placement: "bottom"
      container: ".notifications-widget"

  $(document).on 'init_health_tracker', ->
    $(".health-tracker-top-link").popover
      html: true
      content: -> $("#health_tracker_popover .content").html()
      placement: "bottom"
      trigger: "manual"

  $(document).trigger('init_notifications_popover')
  $(document).trigger('init_health_tracker')

  $(document).on 'click', ".health-tracker-top-link", (e) ->
    $link = $(e.currentTarget)
    $changed_form = $('.health-tracker-item .popover:visible form.changed')
    if $changed_form.size()
      if confirm('Would you like to save your changes?')
        $changed_form.find('#finished').val('true')
        $changed_form.trigger('submit')
    $link.popover('toggle')
    e.preventDefault()

  $(document).on 'click', ".popover .see-all-link", (e) ->
    $link = $(e.currentTarget)
    $changed_form = $('.health-tracker-item .popover:visible form.changed')
    if $changed_form.size()
      if confirm('Would you like to save your changes first?')
        $changed_form.one 'ajax:complete', ->
          window.location = $link.attr('href')
        $changed_form.find('#finished').val('true')
        $changed_form.trigger('submit')
        e.preventDefault()
    true

  $(document).on 'shown.bs.popover', '#top-notifications-link', (e) ->
    $(window).trigger("notificationsArrow")

  $(document).on 'show.bs.popover', ".health-tracker-top-link[data-needs-tracking='true']", (e) ->
    $.post '/settings/set.html', settings: {health_tracker_opened_at: Math.floor(new Date().getTime() / 1000)}
    $('.health-tracker-bubble').hide()
    $(e.target).removeClass('active')  

  $(document).on 'show.bs.popover', '.visible-xs .health-tracker-top-link', (e) ->
    $('#freshwidget-button').css
      zIndex: 0

  $(document).on 'hidden.bs.popover', '.visible-xs .health-tracker-top-link', (e) ->
    $('#freshwidget-button').css
      zIndex: 90000

  if $(".health-tracker-top-link:visible").is('.active')
    $(".health-tracker-top-link:visible").popover('show')

  $(document).on 'symptom_level.selected', '.symptom-level .btn', (e) ->
    $(e.target).closest('.btn-group').find('.btn').removeClass('initially') #clear grey previous selection after new selection is made

  $(document).on 'symptom_level.selected', '.health-tracker-item', (e) ->
    $btn = $ e.target
    window.setTimeout (->
      $btn.closest('form').trigger('submit.rails')
    ), 1000

  $(document).on 'click', '.popover .menu-link', (e) ->
    unless $(@).hasClass 'treatments-link'
      $link = $ e.currentTarget
      screen = $link.data('screen')
      $link.closest('.popover-content')
        .find('.screen').addClass('hide')
        .filter(".#{screen}")
        .removeClass('hide')
      e.preventDefault()
      $(window).resize()

  $(document).on 'ajax:send', '.popover .screen:not(.menu) form', (e) ->
    $form = $ e.target
    return if $form.is('.error')
    return unless $form.is('form')
    $form.closest('.popover-content')
      .find('.screen').addClass('hide')
      .filter('.menu')
      .removeClass('hide')
    $(window).resize()

  $(document).on 'click', '.take-today-select', (e) ->
    $link = $ e.target
    $group = $link.closest('.form-group')
    $checkbox = $group.find('.take-today-checkbox')
    value = $checkbox.prop('checked')
    $checkbox.prop 'checked', !value
    $checkbox.trigger('change')
    $link.toggleClass('checked')

  $(document).on 'change input symptom_level.selected', '.popover form', (e) ->
    $form = $ e.currentTarget
    $form.addClass('changed')

  $(document).on 'ajax:success', '.popover form', (e) ->
    $('.popover form').removeClass('changed')

  $(document)
    .on('click', '.top_notification', ->
      window.location.href = "/notifications/" + $(this).attr("id").replace("notification_", "")
    )
  $('.notification').on 'click', ->
      notification_id = $(this).attr("id").replace("notification_", "")
      window.location.href = "/notifications/" + notification_id



  $(window).on "resize", ->
    if $(".health-tracker-item .visible-xs .popover").is("*")
      $(".health-tracker-item .visible-xs .screen:not(.menu) .scroll").css maxHeight: $(window).height() - 220
      $(".health-tracker-item .visible-xs .popover").css maxHeight: $(window).height()
      $(".health-tracker-item .visible-xs .popover .arrow").css left: $(".health-tracker-top-link:visible").offset().left + 15
    $(".health-tracker-item .hidden-xs .screen:not(.menu) .scroll").css maxHeight: $(window).height() - 320
    $(".health-tracker-item .hidden-xs .screen.menu .scroll").css maxHeight: $(window).height() - 240
    return

  if $('body').hasClass('authorized')
    $('body').data('page-title', $('title').text())
    window.setInterval (->
      return if $('.top_menu_right .popover').is(':visible')
      #get_notifications()
    ), 10000
    return
