class HomeController < ApplicationController
  before_filter :check_profile, only: [:index, :new_home]
  before_filter :handle_condition
  before_filter :assign_variables
  skip_before_filter :authenticate_user!, :check_profile, only: [:skip]

  def skip
    current_user.finished_profile = true
    current_user.save
    redirect_to home_path
  end

  def index
    # Denied access for fun_stuf/introductions/social_posts for guests and /home?condition_id=my_conditions
    redirect_to landing_path, alert: 'You must be logged in to do that' if (current_user.nil? && %w(social_topics introductions).include?(params[:post_type])) || (params[:condition_id] == "my_conditions" && current_user.nil?)

    params[:sort_by] ||= 'posts.last_interaction_at desc'
    params[:post_type] ||= 'everything'

    params[:view] ||= session[:home_feed_view_mode]
    params[:view] ||= 'full'
    session[:home_feed_view_mode] = params[:view]

    @view = params[:view]

    social_category_ids = [PostCategory.find_by_name('Social Support').try(:id)]

    sort_key = params[:sort_by].gsub(/(\sdesc+)|(posts\.)/, '')

    @posts = Post.all

    unless params[:query].blank?
      ids = Post.text_search(query: params[:query]).results.map(&:id)
      @posts = @posts.with_ids(ids)
    end

    # Apply privacy settings
    unless current_user
      @posts = @posts.joins(:user).where('users.privacy = 1 or (users.privacy = 2 and posts.type = ?)', "Review")
      @posts = @posts.where('post_category_id is null OR post_category_id NOT IN (?)', social_category_ids + [PostCategory.find_by_name('Introductions').try(:id)])
    end
    @posts = @posts.for_feed.order(params[:sort_by])
    @posts = @posts.with_user_matching(current_user) if params[:sort_by] =~ /score/
    @posts = @posts.by_category(params[:post_category_id]) if params[:post_category_id].present?
    @posts = @posts.with_user_condition if params[:sort_by] =~ /conditions/
    @posts = @posts.group('posts.id')

    if @condition_id.present?
      if params[:post_type].present?
        any_conditions = @condition_id == 'any'
        case params[:post_type]
          when 'everything', 'All', 'any'
            unless any_conditions
              @base = @posts
              @reviews = @base.by_treatment_condition(@condition_id, current_user)
              @doctor_reviews = @base.by_doctor_condition(@condition_id, current_user)
              @posts = @base.by_conditions(@condition_id, current_user)
              @posts = @reviews + @posts + @doctor_reviews
            end
            @posts
          when 'social_topics'
            @posts = @posts.by_conditions(@condition_id, current_user) unless any_conditions
            @posts = @posts.by_category(social_category_ids)
          when 'fun_stuff'
            @posts = @posts.by_conditions(@condition_id, current_user) unless any_conditions
            @posts = @posts.by_category([PostCategory.find_by_name('Fun Stuff').try(:id)])
            unless current_user
              @posts = @posts.where('users.privacy = 1 or users.privacy = 2')
              @posts = @posts.by_category([PostCategory.find_by_name('Fun Stuff').try(:id)]).order(params[:sort_by])
            end
          when 'introductions'
            @posts = @posts.by_conditions(@condition_id, current_user) unless any_conditions
            @posts = @posts.by_category([PostCategory.find_by_name('Introductions').try(:id)])
          when 'faq'
            @posts = @posts.by_conditions(@condition_id, current_user) unless any_conditions
            @posts = @posts.by_category([PostCategory.find_by_name('FAQ').try(:id)])
          when 'blog'
            @posts = @posts.by_conditions(@condition_id, current_user) unless any_conditions
            @posts = @posts.by_category([PostCategory.find_by_name('Blog').try(:id)])
          when 'medical_topics'
            @posts = @posts.by_conditions(@condition_id, current_user) unless any_conditions
            @posts = @posts.by_category([PostCategory.find_by_name('Medical').try(:id)])
            unless current_user
              @posts = @posts.where('users.privacy = 1 or users.privacy = 2')
              @posts = @posts.by_category([PostCategory.find_by_name('Medical').try(:id)]).order(params[:sort_by])
            end
          when 'all_topics'
            @posts = @posts.by_conditions(@condition_id, current_user) unless any_conditions
            @posts = @posts.by_type('Post')
            unless current_user
              @posts = @posts.where('users.privacy = 1 or users.privacy = 2')
              @posts = @posts.order(params[:sort_by])
            end
          when 'treatment_reviews'
            @posts = @posts.by_type('Review')
            @posts = @posts.by_treatment_condition(@condition_id, current_user) unless any_conditions
          when 'doctor_reviews'
            @posts = @posts.by_type('Review').doctor_reviews
            @posts = @posts.by_doctor_condition(@condition_id, current_user) unless any_conditions
        end
      end
    end
    unless params[:desease_tag_search].blank?
      conditions = params[:desease_tag_search].split ','
      @base = @posts
      @posts = @posts.joins(:conditions).where('conditions.name IN (?)', conditions)
      @posts = @posts.having('COUNT(DISTINCT conditions_posts.condition_id) = ?', conditions.size) if conditions.size > 1
      @reviews = @base.joins(treatment_review: :conditions).where('conditions.name IN (?)', conditions).order(params[:sort_by])
      @reviews = @reviews.having('COUNT(DISTINCT conditions_treatment_reviews.condition_id) = ?', conditions.size) if conditions.size > 1
      @posts = @reviews + @posts
    end

    if @posts.kind_of?(Array)
      @posts.sort_by!{|u| u.send(sort_key).to_i}
      @posts.reverse!
      @posts = Kaminari.paginate_array(@posts).page(params[:page]).per(20)
    else
      @posts = @posts.page(params[:page]).per(20)
    end
  end

  def new_home
    return redirect_to everything_path(params) if params[:query].present?

    @topics = Post.all.for_feed.order('posts.last_interaction_at desc').group('posts.id')
    @condition_id = 'any' if !current_user && @condition_id == 'my_conditions'
    @topics = @topics.by_conditions(@condition_id, current_user) unless @condition_id == 'any'
    @topics = @topics.by_type('Post')
    unless current_user
      @topics = @topics.joins(:user).where('users.privacy = 1 or users.privacy = 2')
    end
    @topics = @topics.limit(5)

    if current_user
      posts_from_favorite = Post.all.not_anonymous
      posts_from_favorite = posts_from_favorite.followed_by(current_user).order('posts.created_at DESC')
      activity_logs = current_user.activity_logs.from_favorite_users

      my_posts = current_user.posts.not_tracking_updates.not_activity_reply
      if params[:filter].present?
        case params[:filter]
          when 'posts'
            posts_from_favorite = posts_from_favorite.not_tracking_updates
            activity_logs = activity_logs.by_type 'Comment'
          when 'photos'
            posts_from_favorite = []
            activity_logs = activity_logs.by_type('Photo').joins(:favorite_user)
            my_posts = []
          when 'tracking'
            my_posts =[]
            activity_logs = []
            posts_from_favorite = posts_from_favorite.tracking_updates
          else

        end
      else
        posts_from_favorite = posts_from_favorite.not_my(current_user.id)
      end

      @combined_records = (activity_logs + posts_from_favorite + my_posts).sort_by{|r| -r.created_at.to_i}

      if @combined_records.present?
        @combined_records = if @combined_records.respond_to?(:page)
          @combined_records.page(params[:page]).per(20)
        else
          Kaminari.paginate_array(@combined_records).page(params[:page]).per(20)
        end
      end
    end

    @active_users = User.last_online.limit(16)

    conditions = ''
    if @condition_id != 'any'
      return if !current_user && @condition_id == 'my_condiitons'
      conditions = @condition_id == 'my_conditions' ? [current_user.main_condition.try(:id)] + current_user.user_conditions.map(&:condition_id) : [Condition.find_by_slug(@condition_id).try(:id)]
      conditions.compact!
    end
    @condition_id = view_context.get_cached_condition_id == 'my_conditions' ? view_context.get_cached_condition_id : Condition.find_by_slug(view_context.get_cached_condition_id).try(:id)
    @condition_id = conditions.join(',') if view_context.get_cached_condition_id == 'my_conditions'
    @condition_id ||= 'any'
    query = "%#{params[:query]}%".downcase
    @summaries = TreatmentSummary.for_summary_page(@condition_id.to_s, params[:sort_by], query)
    @summaries = Kaminari.paginate_array(@summaries).page(params[:page]).per(5)
  end

  private

  def handle_condition
    @condition_id = params[:condition_id]
    if current_user
      @condition_id ||= current_user.settings.condition_id
    end
    @condition_id ||= cookies[:condition_id]

    if @condition_id.present? && !%w(any my_conditions).include?(@condition_id) && @condition_id.to_i.zero?
      @condition = Condition.find_by_slug(@condition_id)
      @condition_id = @condition.to_param
      if @condition.present?
        slug = @condition.slug
        cookies[:selected_community] = current_user.try(:main_condition).try(:name) == @condition.name ? 'main_condition' : @condition.name
      end
    end
    @condition_id ||= 'any'
    cookies[:selected_community] = 'all_conditions' if @condition_id == 'any'
    current_user.settings.condition_id = slug ? slug : @condition_id if current_user
    cookies[:condition_id] = slug ? slug : @condition_id
  end

  def assign_variables
    @post = current_user.posts.new if current_user
    @comment  = Comment.new
    @resource = User.new unless current_user
    @treatment_review = TreatmentReview.new
    @treatment_review.treatment = Treatment.new(period: "#{1.month.ago.strftime("%m-%Y")} - Current", user: current_user, skip_review_update: true)

    if current_user
      @doctor_review = DoctorReview.new
      @doctor_review.doctor = current_user.doctors.new
    end
  end
end
