load_main_link_listeners = ->
  $(document).on "click", ".reply-to-post", (e) ->
    post_id = $(e.target).data("reply-to-post-id");
    $reply_container = $("#add_reply_container_#{post_id}");
    $reply_container.find("textarea").focus();
    $("html, body").animate({
      #FIXME: is magic number, but it looks just like needed
      # it is needed, since otherwise naviagation at the top would cover the textarea
      # The same problem exists for 'Skip To The Latest' link
      scrollTop: $reply_container.offset().top - 56 - 60 - 20
    });

  load_comment_link_listeners()
  load_useful_markers_link_listeners()
  load_subcomments_link_listeners()
  load_useful_link_listeners()
  load_new_subcomment_link_listeners()
  load_add_reply_link_listeners()
  load_bookmark_link_listeners()

load_useful_markers_link_listeners = ->
  $(document).on "click", ".useful_comment_markers_link", (e) ->
    container_id = $(e.target).attr("id").replace("useful_comment_markers_link_", "useful_comment_markers_container_")
    html_content = $("#" + container_id).html()
    $(e.target).popover
      title: "People who found this comment helpful"
      html: true
      content: html_content
      trigger: "click"
    $(e.target).popover('show')

load_useful_link_listeners = ->
  $(document).on "click", ".useful_post_markers_link", (e) ->
    container_id = $(e.target).attr("id").replace("useful_post_markers_link_", "useful_post_markers_container_")
    html_content = $("#" + container_id).html()
    $(e.target).popover
      title: "People who found this post helpful"
      html: true
      content: html_content
    $(e.target).popover('show')

load_subcomments_link_listeners = ->
  $(document).on "click", ".subcomments_link", (e) ->
    container_id = $(e.target).attr("id").replace("_link", "")
    text_area_id = $(e.target).attr("id").replace("subcomments_for_", "new_subcomment_textarea_").replace("_link", "")
    $("#" + container_id).toggle()
      .find('textarea:visible:last').val('').focus()

load_new_subcomment_link_listeners = ->
  $(document).on "click", ".add-subcomment-button", (e) ->
    $link = $(e.target)
    $link.closest('.comment-bottom').find('.subcomment_form:hidden').show().find('textarea').focus()
    $link.closest('.subcomment_button').hide()
    $link.hide()
    e.preventDefault()

load_add_reply_link_listeners = ->
  $(document).on "click", ".add_reply_link", (e) ->
    container_id = $(e.target).attr("id").replace("add_reply_link_", "add_reply_container_")
    $("#" + container_id).show()
    $(e.target).closest('.post-container').find('.read-more-link:visible').click()

load_comment_link_listeners = ->
  $(document).on 'click', '.post-comments', (e) ->
    $link = $(e.target).closest('a')
    $replies_container = $(e.target).closest('.post-container').find('.replies_container')
    $replies_wrapper = $replies_container.closest('.replies-wrapper')
    if $replies_wrapper.is(':visible')
      $post_container = $link.closest('.post-container')
      $post_container.find('.add_reply_container').hide()
      $post_container.find('.reply-to-post').hide()
      $replies_container.html('')
      $replies_wrapper.hide()
    else
      $replies_container.html('Loading...')
      $replies_wrapper.show()
      $.getScript $link.data('href')
    false

  $(document).on 'click', '.post-latest-comment', (e) ->
    $link = $ e.currentTarget
    $replies_container = $(e.target).closest('.post-container').find('.replies_container')
    $replies_wrapper = $replies_container.closest('.replies-wrapper')
    unless $replies_wrapper.is(':visible')
      $replies_container.html('Loading...')
      $replies_wrapper.show()
    $.getScript $link.data('href')
    false

load_bookmark_link_listeners = ->
  $(document).on 'click.rails', '.bookmark-link', (e) ->
    $link = $(e.target).closest('a')
    $link.toggleClass('bookmarked').find('span').toggle()
    true

init_treatment_toggles = ($container) ->
  $checkbox = $container.find('.change-currently-taking')
  $toggle = $container.find('.toggle-currently-taking')
  if $checkbox.size()
    $toggle.toggles
      drag: false
      on: $checkbox.is(':checked'),
      checkbox: $checkbox
      text:
        on: 'Yes'
        off: 'No'

$(document).ready ->
  load_main_link_listeners()
  if $(".scroll-pagination .pagination").length
    $(window).scroll ->
      if $(window).scrollTop() > $(document).height() - $(window).height() - 50
        if $("#no_content").length is 0
          if $(".scroll-pagination .pagination .next a").length > 0
            $(".loading_container").show()
            url = $(".scroll-pagination .pagination .next a").attr("href").replace("from=form", "")
            $.getScript url
          $(".scroll-pagination .pagination").remove()

  $(".loading_container").hide()
  $("#post_review_link").click ->
    $("#review_form").modal
      keyboard: false
      backdrop: "static"
  $("#tabbed_form_link").click ->
    $("#tabbed_review_form").modal
      keyboard: false
      backdrop: "static"
    $('.doctor_review_form #doctor_review_doctor_attributes_country_id').trigger 'change'

  $("body").on "click", ".treatment_label", ->
    $(".treatment_label").removeClass "label-info"
    $(this).addClass "label-info"
    treatment_level = $(this).attr("id").replace("treatment_level_", "")
    $(this).closest(".modal-body").find("#treatment_review_treatment_attributes_level").val treatment_level

  $("body").on "click", ".treatment_type_link", ->
    $(".treatment_type_link").removeClass "label-info"
    $(this).addClass "label-info"
    treatment_type = $(this).data('value')
    $(this).closest(".modal-body").find("#treatment_review_treatment_attributes_treatment_type").val treatment_type

  $("body").on "click", ".doctor-label", ->
    $(".doctor-label").removeClass "label-info"
    $(this).addClass "label-info"
    $(@).closest('form').find('#doctor_review_doctor_attributes_recommended').val $(@).text() is 'Yes'

  $('body').on 'change', '.change-currently_taking', (e) ->
    $(e.target).closest('form').find('.ended-period').toggle()

  $('body').on 'shown.bs.modal', '.review_form_modal', (e) ->
    $modal = $ e.target
    init_treatment_toggles($modal)

  $(document).on 'init_treatment_toggles', ->
    $(".medical-treatments-table .currently_taking").each ->
      init_treatment_toggles $(@)
  $('body').trigger 'init_treatment_toggles'

  $(document).on 'submit', 'form.new_comment.jquery-form', (e) ->
    $form = $ e.target
    $form.ajaxSubmit
      dataType: 'script'
      iframe: true
      success: (responseText, statusText, xhr, $form) ->
        $form.trigger('ajax:complete.rails')
    e.preventDefault()
    false


  $('#reviews-filter').on 'change', ->
    url = $(@).find('option:selected').data 'url'
    $.ajax
      url: url
      dataType: 'script'
      data: {filter: true}
#  $(document).on 'ajax:complete', 'form.new_comment', (e, data, status) ->
#    eval data.responseText.replace(/(\r\n|\n|\r)/gm,"");

  $('.post-container .add-my-team a').on 'click', ->
    $(@).replaceWith 'My Teammate'

  $(document).on 'click', '.expand-replies', ->
    post_activity_id = $(@).data 'post-activity-id'
    $(".expand-replies.activity_post_#{post_activity_id}").not(@).closest('.post-container').remove()