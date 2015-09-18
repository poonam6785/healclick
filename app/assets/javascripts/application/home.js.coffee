# Autocomplete users in any input by @ token
elementFactory = (element, e) ->
  template = $(customItemTemplate).find("span").text("@" + e.val).end()
  element.append template
customItemTemplate = "<div><span />&nbsp;<small /></div>"
window.attach_users_typehead_event = (elements) ->
  elements.sew
    elementFactory: elementFactory
    onFilterChanged: (sew, token, expression) ->
      $.ajax
        url: "/users/autocomplete.json?query=" + expression
        type: "GET"
        success: (result) ->
          newValues = []
          i = 0
          while i < result.options.length
            newValues.push val: result.options[i]
            i++
          sew.setValues newValues
          $(".-sew-list li span").each (index, value) ->
            $(".-sew-list-container").remove() if $(value).text() is "#{token}#{expression}"

$ ->
  # For fixes for touchable devices
  $('body').addClass 'touchable' if Modernizr.touch

  # Dynamic refreshing page on filters change
  $('form.feed-filter select').on 'change', ->
    $(@).closest('form').trigger 'submit'

  # Validate treatment level on submit
  $('body').on 'submit', '.new_treatment_review, .edit_treatment_review', ->
    # Validate uniquness of treatment
    base_treatment = $(@).find('#base_treatment').val()
    new_treatment = $(@).find('#treatment_review_treatment_attributes_treatment').val()
    if new_treatment != base_treatment
      is_unique = false
      $.ajax
        type: 'GET'
        url: '/treatment_reviews/check_unique_name'
        data: {treatment: new_treatment}
        async: false
        success: (data) ->
          is_unique = !data.exists
      if is_unique
        $(@).find('.text-error.hide.error-unique').addClass 'hide'
      else
        $(@).find('.text-error.hide.error-unique').removeClass 'hide'
        return false
    true

  $('body').on 'submit', '.new_doctor_review', ->
    # Validate uniquness of doctor
    doctor_name = $(@).find('#doctor_review_doctor_attributes_name').val()
    doctor_id = $(@).find('#doctor_review_doctor_attributes_id').val()
    unless doctor_id
      is_unique = false
      $.ajax
        type: 'GET'
        url: '/doctor_reviews/check_unique_name'
        data: {doctor: doctor_name}
        async: false
        success: (data) ->
          is_unique = !data.exists
      if is_unique
        $(@).find('.text-error.hide.error-unique').hide()
      else
        $(@).find('.text-error.hide.error-unique').show()
        return false
    true


  window.attach_users_typehead_event($(".users-typehead"))

  $(".modal").on 'shown', '.modal', ->
    window.attach_users_typehead_event $(@).find('.users-typehead')

  $('body').on 'change', '#post_post_category_id', ->
    selected = $(@).find('option:selected').text()
    default_options = $('#default-conditions').html()
    $('.condition_ids').each (index) ->
      condition = $(@).find('option:selected').val()
      switch selected
        when 'Medical'
          $(@).html(default_options).find("option[value='#{condition}']").prop 'selected', true
        when 'Social Support'
          $(@).html default_options
          $(@).find("option[value='#{condition}']").prop 'selected', true


  $('.doctors-filters #country_id').on 'change', ->
    if $(@).find('option:selected').text() is 'United States'
      $('.doctors-filters #state').parent().css({visibility: 'visible'})
    else
      $('.doctors-filters #state').parent().css({visibility: 'hidden'})

  $('.doctors-filters #country_id').trigger 'change'

  if Modernizr && Modernizr.touch
    $('.hover-dropdown')
      .attr('data-toggle', 'dropdown')
      .attr('href', '')
      .attr('onclick', 'javascript:void(0)')
    $('.hover-dropdown').dropdown()
  else
    $('.hover-dropdown').dropdownHover()


  $('#sort_by, #page_category').on 'change', ->
    window.location = $(@).find('option:selected').val()

  $('.community_filter').select2
    placeholder: 'Where do you wanna go?'
  $('.community_filter').on 'change', ->
    value = $(@).find('option:selected').val()
    $.cookie 'selected_community', value, {path: '/'} unless value is ""
    window.location = $(@).find('option:selected').data 'url'

  $('.autocomplete').each ->
    autocomplete_url = $(@).data 'url'
    if autocomplete_url
      $(@).typeahead source: (query, process) ->
        $.getJSON autocomplete_url, query: query, (data) ->
          process data

  # Feed filter select
  $('.feed-filter #filter').on 'change', ->
    window.location = $(@).find('option:selected').data 'url'