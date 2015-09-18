$ ->
  unless typeof google is 'undefined'
    geocoder = new google.maps.Geocoder()
    codeAddress = (address) ->
      geocoder.geocode
        address: address
      , (results, status) ->
        if status is google.maps.GeocoderStatus.OK
          map.setCenter results[0].geometry.location
          map.fitBounds results[0].geometry.viewport

    $('.form-filter-patients-map').on 'submit', ->
      country = $('.form-filter-patients-map #country option:selected').text()
      state = $('.form-filter-patients-map #state option:selected').text()
      address = ''
      address = country unless country is 'Any'
      address += " #{state}" unless state is 'Any'
      codeAddress address if address
      false

      i = 0
      while i < markers.length
        markers[i].setMap null
        i++
      oms.clearMarkers()
      markers.length = 0
      $.getJSON "/users/map.json?" + $(@).serialize(), (users) ->
        $.each users, (key, user) ->
          marker = new google.maps.Marker(
            position: new google.maps.LatLng(user.latitude, user.longitude)
            map: map
          )
          markers.push marker
          marker.id = user.id;
          oms.addMarker(marker)
        $('.gm-style').removeClass('gm-style')
      false

  $state_select = $('.form-filter-patients-map .state-select')
  $('.form-filter-patients-map #country').on 'change', ->
    if $(@).find('option:selected').text() is 'United States'
      $state_select.removeClass 'hide'
    else
      $state_select.find('option[value=""]').prop('selected', true)
      $state_select.addClass 'hide'