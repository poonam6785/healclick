init_medical_editor = ->
  load_period_listeners()
  load_review_button_listeners()
  load_show_review_listeners()
  load_treatment_autocomplete()
  init_symptoms_container()
  init_treatments_container()
  init_chart_filters()
  $(document).on "click", ".remove_post_condition, .remove_treatment_condition", ->
    $(this).closest(".controls").remove()
    return
  return

load_symptom_autocomplete = ->  
  $(".symptom_name:not(.bound)").each ->
    $(this).typeahead source: (query, process) ->
      $.getJSON "/symptoms/autocomplete.json",
        query: query
      , (data) ->
        process data.options
    $(this).addClass "bound"

load_treatment_autocomplete = ->
  $(".treatment_name:not(.bound)").each ->
    $(this).typeahead
      source: (query, process) ->
        $.getJSON "/treatments/autocomplete.json",
          query: query
        , (data) ->
          process data
      updater: (item) ->
        item.replace(/\s\(\d+\)/, '')

    $(this).addClass "bound"

load_period_listeners = ->

  $(".treatment_period").change ->
    period = $(this).val()
    id = $(this).attr("id").replace("treatment_period_", "")
    $.get "/treatments/" + id + "/set_period.js?period=" + period

load_review_button_listeners = ->
  $(document).on "click", ".treatment_review_link", (e) ->
    $link = $(e.target)

load_show_review_listeners = ->
  $(".show_review_link").click ->
    container_id = $(this).attr("id").replace("show_review_link_", "review_container_")
    $("#" + container_id).modal
      keyboard: false
      backdrop: "static"
$(document).on 'click', ".add_condition_link", (e) ->
  $link = $(e.target)  
  $container = $link.closest(".conditions_container")
  html_content = $container.find(".treatment_condition:first").html()
  $container.append html_content

init_symptoms_container = ->
  load_symptom_autocomplete()
  $(document).off 'click', ".btn-toggle-symptoms"
  $(document).on 'click', ".btn-toggle-symptoms", (e) ->
    $link = $(e.target)
    $target = $ $link.data('target')
    $target.slideToggle()
    e.preventDefault()

  $("#symptoms_container .toggle").each ->
    $checkbox = $(@).closest('.symptom-notify').find('input.notify:first')
    $(@).toggles(
      drag: false,
      on: $checkbox.is(':checked'),
      checkbox: $checkbox,
    )

  $('.symptoms-sortable').sortable
    placeholder: "ui-state-highlight"
    forcePlaceholderSize: true

  $(document).on 'sortstart', '.sortable', (e) ->
    if $(window).scrollTop() > $('.navbar-fixed-top').outerHeight()
      $('.navbar-fixed-top').addClass('hide')
  $(document).on 'sortstop', '.sortable', (e) ->
    $('.navbar-fixed-top').removeClass('hide')

  $(document).on 'sortupdate', '.symptoms-sortable', (e) ->
    $sortable = $ e.target
    $sortable.find('.rank').each (i) ->
      $(@).text(i+1)

    symptoms_attributes = []
    $sortable.find('.symptom').each ->
      symptoms_attributes.push {id: $(@).data('symptom-id'), rank: $(@).find('.rank:first').text()}

    $.ajax
      url: $sortable.data('update-path')
      type: 'POST'
      dataType: 'script'
      data:
        _method: 'patch'
        user:
          symptoms_attributes: symptoms_attributes

  $(document).on 'click.rails', '.symptom-remove a', (e) ->
    $(e.target).closest('.symptom').fadeOut()
  $(document).on 'click', '.symptom-level .btn[data-level]', (e) ->
    $btn = $ e.currentTarget
    $btn.closest('.symptom-level').find('.symptom-level-input:first').val($btn.data 'level').trigger 'change'
    $btn.trigger('symptom_level.selected')
    true

  touch_x = null
  touch_y = null
  $(document).on 'touchstart', '.symptom-level .btn', (e) ->
    touch_x = e.originalEvent.touches[0].pageX
    touch_y = e.originalEvent.touches[0].pageY
  $(document).on 'touchend', '.symptom-level .btn', (e) ->
    if e.originalEvent.changedTouches[0].pageX is touch_x && e.originalEvent.changedTouches[0].pageY is touch_y
      $(e.target).click()
  $(document).off 'touchstart', '.toggle, .toggle *'
  $(document).off 'touchmove', '.toggle, .toggle *'
  $(document).on 'touchend', '.toggle, .toggle *', (e) ->
    e.preventDefault()

window.init_treatments_container = ->
  unless Modernizr.touch
    $('.treatments-sortable').sortable
      placeholder: "ui-state-highlight"
      forcePlaceholderSize: true
    $(document).on 'click.rails', '.treatment .selector a', (e) ->
      $link = $(e.target)
      $link.closest('.selector').find('a').removeClass('label-info')
      $link.addClass('label-info')
      true

    $(document).on 'sortupdate', '.treatments-sortable', (e) ->
      $sortable = $ e.target
      $sortable.find('.rank').each (i) ->
        $(@).text(i+1)

      treatments_attributes = []
      $sortable.find('.row.treatment').each ->
        treatments_attributes.push {id: $(@).data('treatment-id'), rank: $(@).find('.rank:first').text()}

      $.ajax
        url: $sortable.data('update-path')
        type: 'POST'
        dataType: 'script'
        data:
          _method: 'patch'
          user:
            treatments_attributes: treatments_attributes

current_series = null
current_lab_series = null
init_chart_filters = ->
  $(document).on 'change', '.treatment_select', (e) ->
    chart_name = $(@).closest('.chart_container').data('chart')
    chart = window[chart_name]
    $select = $(e.target)
    $option = $select.find('option:selected')
    return true unless chart
    chart.yAxis[0].removePlotLine('treatment_band')
    current_series.hide() if current_series
    if chart.get($option.text())
      series = chart.get($option.text())
      series.show()
      current_series = series
    chart.yAxis[0].addPlotLine
      id: 'treatment_band'
      value: 4
      width: 2
      color: 'rgba(68, 170, 213, 0.6)'
      label:
        text: $option.text()
        verticalAlign: 'top'
        style:
          fontSize: '16px'

  $(document).on 'change', '.labs-filter', (e) ->
    chart_name = $(@).closest('.chart_container').data('chart')
    chart = window[chart_name]
    $select = $(e.target)
    $option = $select.find('option:selected')
    return true unless chart
    current_lab_series.hide() if current_lab_series
    if chart.get($option.text())
      for lab in chart.series
        if lab.name is $option.text()
          chart.yAxis[2].setExtremes null, lab.userOptions.maxValue
      chart.yAxis[2].removePlotLine('lab_line')
      series = chart.get($option.text())
      series.show()
      current_lab_series = series
      chart.yAxis[2].addPlotLine
        id: 'lab_line'
        value: chart.yAxis[2].max
        width: 2
        color: 'rgba(68, 170, 213, 0.6)'
        label:
          text: $option.text()
          verticalAlign: 'top'
          style:
            fontSize: '16px'
    else
      chart.yAxis[2].update
        labels:
          enabled: false
      chart.yAxis[2].addPlotLine
        id: 'lab_line'
        value: chart.yAxis[2].max
        width: 2
        color: 'rgba(68, 170, 213, 0.6)'
        label:
          text: 'Labs and other metrics'
          verticalAlign: 'top'
          style:
            fontSize: '16px'


  $(document).on 'change', '.symptom_select', (e) ->
    $select = $(@)
    $option = $select.find('option:selected')
    desired_names = $option.val().split("|")
    chart_name = $(@).closest('.chart_container').data('chart')
    chart = window[chart_name]
    return true unless chart
    chart.yAxis[1].removePlotLine 'symptom-name'
    chart.yAxis[1].addPlotLine({id: 'symptom-name', value: 10, width: 2, label: {text: 'All Symptoms', y: -20, style: {fontSize: '16px'}}}) if $option.text() is 'All Symptoms'
    for symptom in chart.series
      if !symptom.yAxis.axisTitle && symptom.userOptions.yAxis is 1
        if not $option.val()
          if symptom.name is 'Overall Well-Being'
            symptom.hide()
          else
            symptom.show()
        else
          if symptom.name not in desired_names
            symptom.hide()
          else
            chart.yAxis[1].addPlotLine({id: 'symptom-name', value: 10, width: 2, label: {text: symptom.name, y: -20, style: {fontSize: '16px'}}}) if $option.text() isnt 'All Symptoms'
            symptom.show()

$(document).on('click', '.edit-event', (e) ->
  id = $(@).data('id')
  $.get "/events/" + id
  , () ->
  e.preventDefault()
)


$ ->

  a = $('ul#events li')
  page = (a, p) ->
    $('ul#events').html('')
    t = a.slice()
    s = t.splice(p*15, 15)
    $.each(s, ( index, value ) ->
      $('ul#events').append(value)
    )
    if p > 0
      $('.ev-pag li:first-child').removeClass('disabled')
    else
      $('.ev-pag li:first-child').addClass('disabled')
    if p+1 == $(".ev-pag").data("max")
      $('.ev-pag li:last-child').addClass('disabled')
    else
      $('.ev-pag li:last-child').removeClass('disabled')
    $('.ev-pag li').removeClass('active')
    $('.ev-pag li:nth-child(' + (p+2) + ' )').addClass('active')


  ps = 0

  page(a, ps)


  $(document).on('click', '.ev-pag a', (e) ->
    e.preventDefault()
    pp = $(@).parent().data('p')
    if pp == -1 || pp == -2
      if pp == -1
        pp = ps - 1
      else
        pp = ps + 1
      page(a, pp)
    else
      page(a, pp-1)
    ps = pp
    return
  )

  $("input[value='Suggest']").click ->
    window_width = $(window).width()
    if window_width < 440
      $(".set-custom-position").css("margin-top", "40%")
    else
      if window_width < 612
        $(".set-custom-position").css("margin-top", "23.6%")
      else
        if window_width < 640  
          $(".set-custom-position").css("margin-top", "28.6%")
        else
          if window_width < 767  
            $(".set-custom-position").css("margin-top", "20.6%") 
          else
            if window_width < 991  
              $(".set-custom-position").css("margin-top", "8.6%")

  $("#suggest_condition_link").click ->
    $("#suggest_condition_container").show()
    window_width = $(window).width()
    if window_width < 452
      $(".set-custom-position").css("margin-top", "90%")
    else
      if window_width < 525
        $(".set-custom-position").css("margin-top", "70%")
      else
        if window_width < 619
          $(".set-custom-position").css("margin-top", "60%")
        else  
          if window_width < 707
            $(".set-custom-position").css("margin-top", "50%")
          else
            if window_width < 767
              $(".set-custom-position").css("margin-top", "43%")
            else
              if  window_width < 991
                $(".set-custom-position").css("margin-left", "500px") 
              else
                $(".set-custom-position").css("margin-left", "600px")
    return
    
  $(document).on 'submit ajax:beforeSend', 'form.new_event', (e, xhr, settings) ->
    $form = $ e.target
    if $form.find('#event_body').val().length == 0
      $form.addClass 'error'
      $form.find('#event_body').addClass('red-border')
      e.stopPropagation()
      e.preventDefault()
      xhr.abort() if xhr
    else
      $form.removeClass 'error'
      $('#event_body').removeClass('red-border')

  $('.edit-event').on('click', (e) ->
    e.preventDefault();
  )


  $("#medical_tabs a:first").tab "show"  unless $("#medical_tabs>li.active").is("*")
  if $(".user-basic-info-form").is("*")
    $(window).resize ->
      $("#medical_tabs_content .tab-pane").css minHeight: $(window).height() - $(".navbar").height() - $("#medical_tabs").outerHeight() - 80
      return

    $(window).resize()
  init_medical_editor()

  $("body").on 'click', '.add_post_condition_link', ->
    $(@).before $('.post-conditions-template').html()

  $(document).on "medical_editor:init", init_medical_editor

  $.tablesorter.addParser
    id: 'grades'
    is: (s) ->
      false
    format: (s) ->
      s.replace(/Much Better/, 5).replace(/Little Better/, 4).replace(/No Change/, 3).replace(/Little Worse/, 2).replace(/Much Worse/, 1)
    type: "numeric"

  $.tablesorter.addParser
    id: 'review'
    is: (s) ->
      false
    format: (s) ->
      if s.trim().length is 0 then 0 else 1
    type: "numeric"

  $.tablesorter.addParser
    id: 'link_grades'
    is: (s) ->
      false
    format: (s) ->
      s.replace(/MuchBetter/, 5).replace(/LittleBetter/, 4).replace(/NoChange/, 3).replace(/LittleWorse/, 2).replace(/MuchWorse/, 1)
    type: "numeric"

  $(".show-treatments-table").tablesorter
    headers:
      1:
        sorter: 'grades'
      2:
        sorter: false
      3:
        sorter: 'review'
    sortList: [[3,1]]

  $(".medical-treatments-table").tablesorter
    textExtraction: (node) ->
      if $(node).index() is 2
        $(node).find('.text-value').val()
      else
        $(node).text()
    headers:
      0:
        sorter: false
      3:
        sorter: false
      4:
        sorter: false
      5:
        sorter: false
      6:
        sorter: false
        
  $('body').on 'change', '.doctor_review_form #doctor_review_doctor_attributes_country_id', ->
    if $(@).find('option:selected').text() is 'United States'
      $('.doctor_review_form .city-select').addClass('hide')
      $('.doctor_review_form .states-select').removeClass('hide')
      $('.doctor_review_form .city-select input').prop 'disabled', true
    else
      $('.doctor_review_form .city-select').removeClass('hide')
      $('.doctor_review_form .states-select').addClass('hide')
      $('.doctor_review_form .city-select input').prop 'disabled', false    

  $('.doctor_name').typeahead source: (query, process) ->
    $.getJSON "/doctors/autocomplete.json",
      query: query
    , (data) ->
      process data

  
  $('.popular-symptoms :checkbox').on 'change', ->
    input = $('#new-user-tags-symptoms')
    if $(@).prop('checked')
      input.tagsinput 'add', $(@).val()
    else
      input.tagsinput 'remove', $(@).val()

  $('#new-user-symptoms-form').on 'submit', ->
    tagsinpuKeydownEvent = jQuery.Event("keydown")
    tagsinpuKeydownEvent.which = 13
    $('#new-user-tags-form .bootstrap-tagsinput input').trigger(tagsinpuKeydownEvent)
    html = ''
    $.each $('#new-user-tags-symptoms').tagsinput('items'), (index, el) ->
      html += "<input type='hidden' name='popular_symptoms[]' value='#{el}' />"
    $('.popular-symptoms :checkbox').attr('name', '')
    $('#new-user-symptoms-form').append html

  $('.treatments').on 'click', '.take-today-select', ->

    $checkbox = $(@).parent().parent().find(".take-today-checkbox")

    if $checkbox.is(':checked')
      $checkbox.prop('checked', false)
    else
      $checkbox.prop('checked', true)

  window.init_treatments_select2 = ->
    $('#with_selected_treatments, #with_selected_symptoms, #with_selected_labs').select2
      placeholder: 'Selected Items'
      minimumResultsForSearch: -1
  init_treatments_select2()
  $('#with_selected_symptoms').select2
    placeholder: 'Selected Items'
    minimumResultsForSearch: -1

  $(document).on 'change', '#with_selected_treatments', ->
    treatments_ids = []
    $('#treatments_container .bulk-edit-radio:checked').map ->
      treatments_ids.push $(@).val()
    date = $('#tracking_date').val()
    switch $(@).find('option:selected').val()
      when 'current_treatment'
        user = ''
        for id, index in treatments_ids
          user += "user[treatments_attributes][#{index}][id]=#{id}&"
          user += "user[treatments_attributes][#{index}][currently_taking]=1&"
        $.ajax
          type: 'PATCH'
          url: '/treatments/batch_update'
          data: "#{user}tracking_date=#{date}"
          dataType: 'script'
      when 'not_current_treatment'
        user = ''
        for id, index in treatments_ids
          user += "user[treatments_attributes][#{index}][id]=#{id}&"
          user += "user[treatments_attributes][#{index}][currently_taking]=0&"
        $.ajax
          type: 'PATCH'
          url: '/treatments/batch_update'
          data: "#{user}tracking_date=#{date}"
          dataType: 'script'
      when 'delete'
        if confirm 'Are you sure you want to do this? All of your reviews will also be deleted.'
          $.ajax
            type: 'DELETE'
            url: '/treatments/batch_delete'
            data: {ids: treatments_ids.join(','), tracking_date: date}
            dataType: 'script'
      else
    $(@).select2('data', null)

  $('#with_selected_symptoms').on 'change', ->
    symptoms_ids = []
    $('#symptoms_container .bulk-edit-radio:checked').map ->
      symptoms_ids.push $(@).val()
    switch $(@).find('option:selected').val()
      when 'track'
        user = ''
        for id, index in symptoms_ids
          user += "user[symptoms_attributes][#{index}][id]=#{id}&"
          user += "user[symptoms_attributes][#{index}][notify]=1&"
        $.ajax
          type: 'PATCH'
          url: '/symptoms/batch_update'
          data: user
          dataType: 'script'
      when 'not_track'
        user = ''
        for id, index in symptoms_ids
          user += "user[symptoms_attributes][#{index}][id]=#{id}&"
          user += "user[symptoms_attributes][#{index}][notify]=0&"
        $.ajax
          type: 'PATCH'
          url: '/symptoms/batch_update'
          dataType: 'script'
          data: user
      when 'delete'
        if confirm 'Are you sure you want to do this?'
          $.ajax
            type: 'DELETE'
            url: '/symptoms/batch_delete'
            data: {ids: symptoms_ids.join(',')}
            dataType: 'script'
    $(@).select2('data', null)

  $('#labs-container').on 'change', '#with_selected_labs', ->
    labs_ids = []
    $('#labs-container .bulk-edit-radio:checked').map ->
      labs_ids.push $(@).val()
    switch $(@).find('option:selected').val()
      when 'delete'
        if confirm 'Are you sure you want to do this?'
          $.ajax
            type: 'DELETE'
            url: '/labs/batch_delete'
            data: {ids: labs_ids.join(','), date: $('#labs-container #date').val()}
            dataType: 'script'

  $(document).on 'click', '.medical-submit', ->
    $(@).prop('disabled', true).text('Saving...')
    $($(@).data('target')).trigger 'submit'

  $('#labs-container').on 'keydown', '.lab-current-value', (e) ->
    char = String.fromCharCode(e.keyCode)
    return (!jQuery.isArray(char) && (char - parseFloat(char) + 1) >= 0) || (e.keyCode == 8) || (e.keyCode == 190)

  # Prevent living a page without saving
  $(document).on 'change', '.symptom-level-input, .current-dose, .take-today-checkbox, .lab-current-value, .lab-unit', ->
    if $('#medical_tabs').length > 0
      window.onbeforeunload = (e) =>
        if !$('.popular-symptoms').is(':visible')
          message = "Are you sure? Your unsaved changes will be lost. So be careful!"
          e = e || window.event
          if (e)
            e.returnValue = message;
          return message
        else
          return null

  $('#treatments_container').on 'click', '.taken-link', ->
    $(@).toggleClass 'label-info'
    if $(@).hasClass 'label-info'
      $(@).text 'Yes'
      $(@).siblings(':checkbox').prop('checked', true).trigger('change')
    else
      $(@).text '?'
      $(@).siblings(':checkbox').prop('checked', false).trigger('change')
    false

  $('.scrollable-area').css({'height': "#{$(window).height() - 90}px"})