load_delete_listeners = ->
  $(".remove_element:not(.bound)").each ->
    $(this).click ->
      $(this).parent().parent().remove()

    $(this).addClass "bound"

load_add_listener = (item_type) ->
  $(".add_" + item_type).click ->
    count = $("." + item_type + "_selector").length
    element = "<div class=\"" + item_type + "_selector\">" + $("." + item_type + "_selector").first().html() + "</div>"
    element = element.replace(/bound/g, "")
    element = element.replace(/display\:none/g, "")
    element = element.replace(RegExp(" bound", "g"), "")
    element = element.replace(/index_0/g, "index_" + count)
    $("#" + item_type + "s_container").append element
    $("." + item_type + "_selector").last().val ""
    load_delete_listeners()
    load_symptom_autocomplete()  if item_type is "symptom"
    load_treatment_autocomplete()  if item_type is "treatment"

load_popup_link_listeners = ->
  $(document).on 'click', 'a.profile-popup-link', (e) ->
    $link = $(e.target).closest('a.profile-popup-link')
    $.get $link.attr('href'), (data) ->
      $link.attr('data-content', data);
      $link.popover
        animation: true
        html: true
        trigger: "manual"
        content: data
        container: 'body'
        title: ''        

      $link.popover("show")
      $link.addClass('popover-active')

      # Format the title
      a = $('.profile-popup .profile-title').html()
      $('.profile-popup').closest('.popover').find('h3.popover-title').html(a)
      #$('.profile-popup .profile-title').hide()
    false

init_tag_inputs = ->
  confirmKeys = [13, 9, 188]
  #bootstrap tagsinput is weird. there is no reliable way to check if it's initialized
  #and it will throw error if you try to initialize it twice or destroy uninitialized input. thankfully there is a magic (terrible) trick (hack)
  $('#tags-symptoms').tagsinput('input') #this call initializes input if it's not initialized and doesn't throw error
  $('#tags-symptoms').tagsinput('destroy') # this call destroys input that is guaranteed to be initialized
  $('#tags-symptoms, #new-user-tags-symptoms').tagsinput # this call initializes it again with desired params
    confirmKeys: confirmKeys
    typeahead:
      source: (query) ->
        $.get('/symptoms/autocomplete.json', { query: query })

  $('#tags-treatments').tagsinput('input')
  $('#tags-treatments').tagsinput('destroy')
  $('#tags-treatments').tagsinput
    confirmKeys: confirmKeys
    typeahead:
      source: (query) ->
        $.get('/treatments/autocomplete.json', { query: query })

  $('#tags-labs').tagsinput('input')
  $('#tags-labs').tagsinput('destroy')
  $('#tags-labs').tagsinput
    confirmKeys: confirmKeys
    typeahead:
      source: (query) ->
        $.get('/labs/autocomplete.json', { query: query })

  $('#tags-doctors').tagsinput('input')
  $('#tags-doctors').tagsinput('destroy')
  $('#tags-doctors').tagsinput
    confirmKeys: confirmKeys
    typeahead:
      source: (query) ->
        $.get('/doctors/autocomplete.json', { query: query })

  return

window.init_tag_inputs = init_tag_inputs

$ ->
  confirmKeys = [13, 9, 188]

  $(".load_symptoms_chart").trigger('click.rails')
  $(".load_symptoms_series").trigger('click.rails')

  $('#time-series-limit button').on 'click', ->
    $.ajax
      url: '/time_series_analysis'
      dataType: 'script'
      data: {limit: $(@).data('limit')}

  load_delete_listeners()
  load_add_listener "condition"
  load_add_listener "symptom"
  load_add_listener "treatment"
  load_popup_link_listeners()
  init_tag_inputs()
  $(".quick-message-link").click ->
    $("#quick_message_container").modal
      keyboard: false
      backdrop: "static"

  $(document).on "medical_editor:init", init_tag_inputs

  $(document).on 'click', '.symptoms-submit', (e) ->
    $(e.target).text('Adding...').prop 'disabled', 'disabled'
    tagsinpuKeydownEvent = jQuery.Event("keydown")
    tagsinpuKeydownEvent.which = 13
    $('#tags-symptoms').tagsinput('input').trigger(tagsinpuKeydownEvent)
    symptoms = $('#tags-symptoms').val()
    $.ajax
      type: 'POST'
      dataType: 'script'
      url: '/symptoms/batch_create.js'
      data: "symptom[symptom]=#{symptoms}"
    false

  $(document).on 'click', '.symptom-level .btn[data-level]', (e) ->
    $(this).closest('.symptom-level').find(".btn.active").removeClass("active")
      
  $(document).on 'click', '.treatments-submit', (e) ->
    $(e.target).text('Adding...').prop 'disabled', 'disabled'
    tagsinpuKeydownEvent = jQuery.Event("keydown")
    tagsinpuKeydownEvent.which = 13
    $('#tags-treatments').tagsinput('input').trigger(tagsinpuKeydownEvent)
    treatments = $('#tags-treatments').val()
    datepicker = $('#treatments-datepicker').data('datepicker')
    if datepicker
      date = $.format.date($('#treatments-datepicker').data('datepicker').viewDate, "yyyy-MM-dd")
    date = '' unless date
    $.ajax
      type: 'POST'
      dataType: 'script'
      url: '/treatments/batch_create.js'
      data: "treatment[treatment]=#{treatments}&date=#{date}"
    false

  $(document).on 'click', '.labs-submit', (e) ->
    $(e.target).text('Adding...').prop 'disabled', 'disabled'
    tagsinpuKeydownEvent = jQuery.Event("keydown")
    tagsinpuKeydownEvent.which = 13
    $('#tags-labs').tagsinput('input').trigger(tagsinpuKeydownEvent)
    labs = $('#tags-labs').val()
    datepicker = $('#labs-datepicker').data('datepicker')
    if datepicker && datepicker.dates
      date = $.format.date($('#labs-datepicker').data('datepicker').viewDate, "yyyy-MM-dd")
    date = '' unless date
    $.ajax
      type: 'POST'
      dataType: 'script'
      url: '/labs/batch_create.js'
      data: "lab[name]=#{labs}&date=#{date}"
    false

  $(document).on 'click', '.doctors-submit', (e) ->
    $(e.target).text('Adding...').prop 'disabled', 'disabled'
    tagsinpuKeydownEvent = jQuery.Event("keydown")
    tagsinpuKeydownEvent.which = 13
    $('#tags-doctors').tagsinput('input').trigger(tagsinpuKeydownEvent)
    doctors = $('#tags-doctors').val()
    $.ajax
      type: 'POST'
      dataType: 'script'
      url: '/doctors/batch_create.js'
      data: "doctors[name]=#{doctors}"
    false

  # Manual trigger keydown event when user trying to type comma with open autocomplete list
  $(document).on 'keyup', '.bootstrap-tagsinput input', (e) ->
    tagsinpuKeydownEvent = jQuery.Event("keydown")
    tagsinpuKeydownEvent.which = 13
    _this = $(e.target)
    if e.which in confirmKeys
      setTimeout(->
        _this.trigger(tagsinpuKeydownEvent)
      ,100)

  # Save treatment type on change
  $('#treatments_container').on 'change', '.select-treatment-type', ->
    treatment_id = $(@).data('treatment-id')
    $.ajax
      type: 'PUT'
      url: "/treatments/#{treatment_id}/set_type"
      data: {type: $(@).find('option:selected').val()}

  # Handle profile's state dropdown
  $('#user_country_id').on 'change', ->
    if $(@).find('option:selected').text() is 'United States'
      $('.control-group.country-select').removeClass('hide').find('select').prop('disabled', false)
    else
      $('.control-group.country-select').addClass('hide').find('select').prop('disabled', true)
  $('#user_country_id').trigger 'change'

  # Handle email notification settings at /settings
  $('.notification-table :checkbox').on 'change', ->
    $(@).closest('tr').find(':checkbox').not(@).prop 'checked', !$(@).prop('checked') if $(@).prop 'checked'

  
  $("input[type='submit']").on 'click', ->
    $("#conditions_container").removeClass("hide")

