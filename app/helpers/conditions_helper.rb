module ConditionsHelper
  def condition_options_for_menu
    current_user ? current_user.conditions + Condition.not_user_conditions(current_user) : Condition.active
  end

  def community_options
    options = [['', '']]
    if current_user
      options << ["#{current_user.main_condition.try(:name)} Room", 'main_condition', { data: { url: (params[:controller] == 'my_click' || params[:action] == 'bookmarks' || (params[:controller] == 'posts' && params[:action] == 'show')) ? conditions_path(current_user.main_condition.try(:slug)) : url_for(params.merge(condition_id: current_user.main_condition.try(:slug))) } }]
      options << ['My Conditions', 'my_conditions', { data: { url: (params[:controller] == 'my_click' || params[:action] == 'bookmarks' || params[:action] == 'my_topics' || (params[:controller] == 'posts' && params[:action] == 'show')) ? conditions_path('my_conditions') : url_for(params.merge(condition_id: 'my_conditions', query: params[:query])) } }]
    end
    options << ['All Conditions', 'all_conditions', data: { url: (params[:controller] == 'my_click' || params[:action] == 'bookmarks' || params[:action] == 'my_topics') ? conditions_path('any') : url_for(params.merge(condition_id: 'any', query: params[:query])) }]
    condition_options_for_menu.each do |cond|
      options << ["#{cond.name} Room", cond.name, data: { url: (params[:controller] == 'my_click' || params[:action] == 'bookmarks' || params[:action] == 'my_topics' || (params[:action] == 'show' && params[:controller] == 'posts')) ? conditions_path(cond.slug) : url_for(params.merge(condition_id: cond.slug, query: params[:query])) }]
    end
    options
  end

  def options_for_review_conditions
    summary = @treatment_summaries.first
    all_count = summary.try(:post_count_by_condition, current_user, 'any').try(:to_i)
    options = [["All Conditions (#{pluralize all_count, 'review'})", 'all_conditions', data: { url: url_for(params.merge(review_condition_id: 'any', query: params[:query]))}]]
    if current_user
      main_condition_count = summary.try(:post_count_by_condition, current_user, current_user.main_condition.try(:slug))
      my_conditions_count = summary.try(:post_count_by_condition, current_user, 'my_conditions')
      options << ["#{current_user.main_condition.try(:name)} (#{pluralize main_condition_count, 'review'})", 'main_condition', { data: { url: url_for(params.merge(review_condition_id: current_user.main_condition.try(:slug)))}}] if main_condition_count > 0
      options << ["My Conditions (#{pluralize my_conditions_count, 'review'})", 'my_conditions', { data: { url: url_for(params.merge(review_condition_id: 'my_conditions', query: params[:query]))}}] if my_conditions_count > 0
    end
    condition_options_for_menu.each do |cond|
      count = summary.try(:post_count_by_condition, current_user, cond.slug)
      options << ["#{cond.name} (#{pluralize count, 'review'})", cond.name, data: { url: url_for(params.merge(review_condition_id: cond.slug, query: params[:query]))}] if count > 0
    end
    options
  end
end