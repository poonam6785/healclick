module ViewsHelper
  # Conditional paths for autocomplete plugin
  def autocomplete_url_helper
    autocomplete_treatment_reviews_path if params[:controller] == 'reviews' || (@post.present? && @post.is_a?(Review))
  end

  def my_own_activity?(user)
  	params[:controller] == 'personal_profiles' && params[:action] == 'activity' && current_user == user
  end

  def show_title?
  	%w(home my_click personal_profiles doctor_reviews reviews).include?(params[:controller])
  end

  def community_title_for_treatment_reviews(condition = get_cached_condition_id)
    return 'ME/CFS' if condition == 'me-cfs'
    return 'All Conditions' if condition == 'any'
    condition.try(:gsub, /-/, ' ').try(:titleize)
  end

  def selected_page_category
    get_params = {condition_id: params[:condition_id], query: params[:query]}
    return summary_reviews_path(get_params) if params[:controller] == 'reviews'
    return home_path(get_params) if request.path == '/home' || request.fullpath == '/'
    return topics_path(get_params) if params[:post_type] == 'all_topics'
    return url_for(params.merge(get_params.merge(post_type: 'medical_topics'))) if params[:post_type] == 'medical_topics'
    return social_topics_path(get_params) if params[:post_type] == 'social_topics'
    return fun_stuff_path(get_params) if params[:post_type] == 'fun_stuff'
    return introductions_path(get_params) if params[:post_type] == 'introductions'
    URI.unescape request.fullpath
  end

  def show_number_of_search_items?
    params[:query].present? || params[:titles_search].present? || params[:by_member_search].present? || params[:desease_tag_search].present?
  end

  def search_by_url_helper
    params[:controller] == 'reviews' && params[:action] == 'index' ? '' : home_path
  end

  def render_community_filter?
    !%w(bookmarks my_topics).include? params[:action]
  end

  def community_title_for_home(type)
    community = cookies[:selected_community]
    community = current_user.main_condition.try(:name) if community == 'main_condition' && current_user
    community = community.try(:titleize)
    "#{truncate community, length: 25, omission: '...'} #{type}"
  end

  def show_questionnaire?
    SystemSetting.get_boolean_value(:enabled_questionnaire) && current_user && !current_user.completed_survey?
  end

  def user_has_unanswered_questions?
    @question = Question.by_question_category_id(current_user.question_categories.map(&:id)).unanswered_by(current_user).first
    !@question.nil?
  end

  def add_noindex?
    NoindexRule.all.map(&:url).each do |rule|
      return true if request.path_info == rule
    end
    return true if params[:controller] == 'posts' && params[:action] == 'show' && @post.present? && (!@post.treatment_review_id.blank? || !@post.doctor_review_id.blank?)
    false
  end

  def show_expand_replies?(content)
    !(content =~ /Photo<\/a>/)
  end
  
  def summary_pages?
    params[:controller] == 'reviews' && params[:action] == 'index' && !current_user
  end
end