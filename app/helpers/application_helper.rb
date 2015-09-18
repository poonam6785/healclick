require 'evolve_chat'

module ApplicationHelper
  include AutoHtml

  def resource
    @resource
  end

  def authentication_protocol
    Rails.env.production? ? 'https' : 'http'
  end

  def render_svg partial_name
    render partial: "shared/svg/#{partial_name}", formats: [:svg]
  end

  def auth_token_tag
    tag(:input, :type => "hidden", :name => request_forgery_protection_token.to_s, :value => form_authenticity_token)
  end

  def human_sortable(sort)
    case sort
    when 'users.created_at desc'
      "Recently Joined"
    when 'users.first_name asc'
      "Alphabetical"
    when 'conditions.name asc'
      "Primary Diagnosis"
    when 'users.last_sign_in_at desc'
      "Recently Online"
    when 'users.updated_at desc'
      "Recently Updated"
    when 'posts.last_interaction_at desc'
      "Latest Activity"
    when 'users.username asc'
      "Alphabetical"
    when 'posts.created_at desc'
      "Newest"
    when 'posts.interactions_count desc'
      "Most Interactions"
    when 'posts.helpfuls_count desc'
      "Most Helpful"
    when 'posts.views_count desc'
      "Most Viewed"
    when 'posts.treatment_level desc, posts.updated_at desc'
      "Best Effectiveness"
    when 'treatment_summaries.updated_at desc'
      "Latest Activity"
    when 'treatment_summaries.reviews_count desc'
      "Most Reviews"
    when 'treatment_summaries.review_average desc'
      "Highest Rated"
    else
      sort
    end
  end

  def render_flash
    html = ""
    flash.map do |key, value|
      notice_class = ''

      case key.to_s
      when 'notice'
        notice_class = 'success'
      when 'error'
        notice_class = 'danger'
      when 'alert'
        notice_class = 'warning'
      end

      html += content_tag(:div, value, class: "alert alert-#{notice_class}")
    end
    html.html_safe
  end

  def user_rounded_avatar(user, options = {})
    return image_tag "no-photo-male.jpg", options if user.blank?

    content_tag(:div, "", class: "user-rounded-avatar", style: "background-image: url('#{user_avatar_url(user, :medium, options)}')")
  end

  def user_avatar_url(user, style = :original, options = nil)
    options ||= {}
    if user.profile_photo.present? && !options[:anonymous]      
      return user.profile_photo.try(:attachment).try(:url, style)      
    end    
    asset_path("no-photo-#{(gender = user.try(:gender)).present? ? gender : 'male'}.jpg")
  end

  def user_avatar(user, options = {})
    return image_tag "no-photo-male.jpg", options if user.blank?
    options[:class] ||= 'img-responsive'
    image_tag user_avatar_url(user, options.fetch(:style, :medium), options), options
  end

  def user_display_name(user)
    return user.username if user.username.to_s.strip.present?
    "No Name"
  end

  def user_sorter_path(sorting_column)
    "?#{params.reject{|k| ["controller", "action", "utf8", "commit", "sort_by"].include?(k)}.map{|k, v| "#{k}=#{v}"}.join("&")}&sort_by=#{sorting_column}"
  end

  def post_sorter_path(sorting_column)
    "?#{params.reject{|k| ["controller", "action", "utf8", "commit", "sort_by", "page"].include?(k)}.map{|k, v| "#{k}=#{v}"}.join("&")}&sort_by=#{sorting_column}"
  end

  def review_sorter_path(sorting_column)
    "?#{params.reject{|k| ["controller", "action", "utf8", "commit", "sort_by", "page"].include?(k)}.map{|k, v| "#{k}=#{v}"}.join("&")}&sort_by=#{sorting_column}"
  end

  def treatment_sorter_path(sorting_column)
    "?#{params.reject{|k| ["controller", "action", "utf8", "commit", "sort_by", "page"].include?(k)}.map{|k, v| "#{k}=#{v}"}.join("&")}&sort_by=#{sorting_column}"
  end

  def linked_mentions(text)
    return text if text.blank?
    pattern   = /@([a-zA-Z0-9_\.]*)/
    usernames = text.scan(pattern).flatten.map{|u| u unless u.blank?}.compact
    links     = usernames.map do |username|
      username = username.gsub('_', ' ')
      link_to "@#{username}", profile_path(username)
    end

    usernames.each_with_index do |username, index|
      text.gsub!("@#{username}", current_user ? links[index] : '@[Private]')
    end

    auto_html text do
      #simple_format
      youtube_custom
      vimeo_custom
      empty_lines
      image
      link target: :_blank, rel: :nofollow
      # remove_protocol_from_images
    end.html_safe
  end

  def notification_author_link(object, size = "30x30")
    unless %w(LUV_REPLY LUV_POST LUV_COMMENT HELPFUL_COMMENT HELPFUL_REPLY HELPFUL_DISCUSSION HELPFUL_DISCUSSION).include?(object.notification_type)
      if object.unscoped_comment.present?
        return "#{user_avatar(User.new, size: size)} Anonymous".html_safe if (object.unscoped_comment.anonymous)
      else
        return "#{user_avatar(User.new, size: size)} Anonymous".html_safe if (object.notifiable.respond_to?(:anonymous) && object.notifiable.anonymous)
      end
    end

    (link_to(user_avatar(object.from_user, size: size), profile_url(object.from_user.username)) +
    " " +
    link_to((object.from_user.username || object.from_user.username), profile_url(object.from_user.username))).html_safe
  end

  def notification_content(notification, truncated_to = 100, linked = false, index = false)
    notification.content = "#{index}. #{notification.content}" if index 
    content = simple_format(truncate(notification.content.html_safe, :length => truncated_to, :omission => "... (continued)".html_safe, escape: false))
    if notification.notifiable.is_a?(Comment) && notification.notifiable.commentable.is_a?(Photo)
      if linked
        photo_link = link_to 'Photo', "#{user_photo_path(notification.notifiable.commentable.user, notification.notifiable.commentable)}#comment_#{notification.notifiable.id}"
      else
        photo_link = 'Photo'
      end

      content.gsub!('[PHOTO]', photo_link)
    end

    if linked
      sender_link = link_to((notification.from_user.username || notification.from_user.username), profile_path(notification.from_user.username))
    else
      sender_link = (notification.from_user.username || notification.from_user.username)
    end

    if %w(LUV_REPLY LUV_POST LUV_COMMENT HELPFUL_COMMENT HELPFUL_REPLY HELPFUL_DISCUSSION HELPFUL_DISCUSSION).include?(notification.notification_type)
      content.gsub!('[SENDER]', sender_link)
    else
      if notification.unscoped_comment.present?
        content.gsub!('[SENDER]', notification.unscoped_comment.anonymous ? "Anonymous" : sender_link)
      else
        content.gsub!('[SENDER]', (notification.notifiable.respond_to?(:anonymous) && notification.notifiable.anonymous) ? "Anonymous" : sender_link)
      end
    end

    if notification.notifiable.is_a?(Post)
      if linked
        content_link = link_to(truncate(notification.notifiable.title, :length => truncated_to), post_review_path_helper(notification.notifiable))
      else
        content_link = truncate(notification.notifiable.title, :length => truncated_to)
      end

      content.gsub!('[SUBJECT]', content_link.to_s)
    elsif notification.notifiable.is_a?(Comment)
      if notification.notifiable.commentable.blank?
        content.gsub!('[SUBJECT]', "Not Available Anymore")
      else
        if linked
          content_link = link_to(truncate(notification.notifiable.content.html_safe, :length => truncated_to), "#{post_path(notification.notifiable.commentable)}?expanded=true#comment_#{notification.notifiable.id}")
        else
          if notification.notification_type == 'COMMENTED_ON_REPLY'
            comment_content = notification.notifiable.parent.present? ? notification.notifiable.parent.content : notification.notifiable.content
          else
            comment_content = notification.notifiable.content
          end
          content_link = truncate(comment_content.html_safe, :length => truncated_to)
        end

        content.gsub!('[SUBJECT]', "\"#{content_link}\"")
      end
    end
    content.html_safe
  end

  def matching_tag(word)
    if current_user.tag_list.map(&:downcase).include?(word.downcase.strip)
      content_tag :strong, word, style: "color: #77c270"
    else
      word
    end
  end

  def profile_tab_class(tab_type)
    case tab_type
    when 'basic_info'
      return 'active' if request.path =~ /basic_info/
    when 'symptoms'
      return 'active' if request.path =~ /symptoms/
    when 'treatments'
      return 'active' if request.path =~ /treatments/
    when 'profile'
      return 'active' if request.path =~ /profile/
    when 'activity'
      return 'active' if request.path =~ /activity/
    end
  end

  def render_chat    
    return if is_mobile_device? || is_tablet_device?
    return unless current_user.is_a?(User)
    return unless Rails.env.production?

    photo_src = current_user.profile_photo.try(:attachment).try(:url, :medium)

    photo_src = if photo_src.blank?
      "no-photo-#{current_user.gender}.jpg".gsub('photo-.jpg', 'photo-male.jpg')
    else
      'https:' + photo_src
    end

    EnvolveChat::ChatRenderer.get_html("144645-GFZxk3nUSMQsQLXH9drC9FAR9CPUwmRZ",
      :first_name => current_user.username,
      :last_name => "",
      :is_admin => current_user.is_admin,
      :pic => photo_src,
      :people_list_header_text => "HealClick Chat",
      :people_here_text => "People online",
      :groups => [{:id => "forum_sec", :name => "Forum Chat"}]
    ).html_safe
  end

  def own_profile_links(user)
    %w(personal_profiles users photos settings notifications messages).include?(params[:controller]) && %w(basic_info my_health show favorite_list favorited_me index profile_photo crop_photo map new sent).include?(params[:action]) && (current_user == user || user.nil?)
  end

  def current_user_param
    "user-#{current_user.to_param}"
  end

  def favorite_polymorph_path
    if own_profile_links(current_user)
      favorite_list_users_path
    else
      my_click_path
    end
  end

  def title(text, setting_key = nil)
    meta_settings = SystemSetting.get_values([
      "page_title_#{setting_key}", 
      'page_title_template', 
      'page_title_sitename',
      'page_title_separator'
    ])
    title = meta_settings.fetch("page_title_#{setting_key}", text)
    separator = title.present? ? meta_settings.fetch('page_title_separator', "") : ''
    title = (meta_settings['page_title_template'] ||= '%%sitename%%')
      .sub('%%page%%', title.to_s)
      .sub("%%sep%%", separator.to_s)
      .sub("%%sitename%%", meta_settings.fetch("page_title_sitename", "Healclick").to_s)
      .strip
    meta title: title
    title
  end

  def spinner_icon
    content_tag(:i, "", class: 'fa fa-spinner fa-spin').gsub("\"", "'").html_safe
  end

  def logo_url_helper
    root_path(get_cached_condition_id)
  end  

  def body_class
    c = params[:controller].gsub("/", "-")
    c << ' ' + params[:action]
    c << ' authorized' if current_user.present?
    c << ' unauthorized' unless current_user.present?
    c
  end

  def category_is_active?(category)
    return 'active' if params[:action] == 'basic_info' && category == 'basic_info'
    return 'active' if params[:action] == 'my_health' && category == 'my_health'
    return 'active' if params[:action] == 'favorite_list' && category == 'favorite_list'
    return 'active' if params[:action] == 'favorited_me' && category == 'favorited_me'
    return 'active' if params[:controller] == 'home' && params[:post_type] == 'any' && category == 'everything'
    return 'active' if params[:controller] == 'photos' && category == 'photos'
    return 'active' if params[:controller] == 'reviews' && category == 'treatment_reviews'
    return 'active' if params[:post_type] == 'medical_topics' && category == 'medical_topics'
    return 'active' if params[:post_type] == 'social_topics' && category == 'social_topics'
    return 'active' if params[:post_type] == 'fun_stuff' && category == 'fun_stuff'
    return 'active' if params[:post_type] == 'introductions' && category == 'introductions'   
    return 'active' if params[:post_type] == 'faq' && category == 'faq'
    return 'active' if params[:post_type] == 'blog' && category == 'blog'
    return 'active' if params[:post_type] == 'all_topics' && category == 'all_topics'
    nil
  end

  def get_cached_condition_id
    return params[:condition_id] if params[:condition_id].present?
    return current_user.settings.condition_id if current_user && !current_user.settings.condition_id.blank?
    return session[:condition_id] unless session[:condition_id].blank?
    'any'
  end

  # Icons
  def my_fa_icon(type)
    fa_class = "fa fa-plus-square" if type == 'add'
    "<i class='#{fa_class}'></i>".html_safe
  end

  def meta_tag(title, description)
    content_for :title do
      title
    end

    content_for :meta_description do
      description
    end
  end

  def after_sign_up_steps?
    params[:commit] == 'Continue' || params[:commit] == 'as_topic'
  end
end
