module PostsHelper
  def author_link(object, size = "150x150", options = nil)
    options ||= {}
    render partial: 'shared/post_author', locals: {object: object, size: size}.merge(options)
  end

  def conditions_options_for_post(condition = nil)
    condition_id = condition.respond_to?(:id) ? condition.id : condition
    options = []
    options << ['My Conditions', 'my_conditions'] if current_user
    options_for_select(options + Condition.active.where("name is not null and name != ?", "").order('name asc').map{|c| [c.name, c.id]}, condition_id)
  end

  def replies_number(value)
    "<span>#{value}</span>" + ('reply').pluralize(value)
  end

  def options_for_post_type
    if params[:controller] == 'my_click'
      [
        ['Everything', 'everything'],
        ['Topics', 'all_topics'],
        ['Treatments', 'treatment_reviews'],
        ['Doctors', 'doctor_reviews']
      ]
    else
      [
        ['Everything', 'everything'],
        ['Topics', 'all_topics'],
        ['Medical Topics', 'medical_topics'],
        ['Social Topics', 'social_topics'],
        ['Treatments', 'treatment_reviews'],
        ['Doctors', 'doctor_reviews']
      ]
    end
  end

  def search_url_helper
    return summary_reviews_path if params[:controller] == 'reviews' && params[:action] == 'index'
    return summary_reviews_path if params[:controller] == 'posts' && params[:action] == 'show' && @post.present? && @post.is_a?(Review)
    return topics_path if params[:controller] == 'posts' && params[:action] == 'show' && @post.present? && @post.is_a?(Post)
    ""
  end

  def subtopic_link_hekper(condition)
    if @post.present?
      return link_to 'Fun Stuff', fun_stuff_path(condition_id: condition) if @post.post_category.try(:name) == 'Fun Stuff'
      return link_to 'Medical', medical_topics_path(condition_id: condition) if @post.post_category.try(:name) == 'Medical'
      return link_to 'Social Support', social_topics_path(condition_id: condition) if @post.post_category.try(:name) == 'Social Support'
    end
    link_to 'Introductions', introductions_path(condition_id: condition) 
  end

  def condition_for_review
    return 'my_conditions' if ['bookmarks', 'my_topics'].include?(params[:action]) || params[:controller] == 'my_click'
    return get_cached_condition_id
  end

  def poly_luv_id(post)
    post.comment_id.blank? ? "post_luv_container_#{post.id}" : "comment_luv_container_#{post.comment_id}"
  end

  def poly_helpful_id(post)
    post.comment_id.blank? ? "post_helpful_container_#{post.id}" : "comment_helpful_container_#{post.comment_id}"
  end

  def post_categories_options
    categories = []
    categories += PostCategory.where(name: ['Medical', 'Introductions', 'Fun Stuff', 'Social Support']).order('name ASC').map{|c| [c.name, c.id]}
    if current_user && current_user.is_admin?
      categories += PostCategory.where(name: %w(FAQ Blog)).map{|c| [c.name, c.id]}
    end
    categories
  end

  def post_review_path_helper(post)
    return post_path(post) if post.type == 'Post'
    return treatment_summary_review_path(post.treatment_review.treatment.treatment_summary, post) if post.treatment_review.present? && post.treatment_review.treatment.present? && post.treatment_review.treatment.treatment_summary.present?
    return doctor_summary_review_path_path(post.doctor_review.doctor.doctor_summary, post) if post.doctor_review.present? && post.doctor_review.doctor.present? && post.doctor_review.doctor.doctor_summary.present?
    post_path(post)
  end
end
