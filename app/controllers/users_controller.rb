class UsersController < ApplicationController

  before_filter :redirect_to_landing, :load_user
  before_action :require_admin, only: [:time_series_analysis_admin]

  def autocomplete
    if params[:query].length > 2
      @users = User.where('username LIKE ?', "%#{params[:query]}%").limit(10).active
    else
      @users = []
    end

    render json: {options: @users.map{|user| user.username.sub(' ', '_') if user.username.present?}.compact}.to_json
  end

  def index
    params[:sort_by] ||= 'users.created_at desc'
    #params[:last_signed_in] ||= 'year'

    if params[:query].present?
      ids = User.text_search(query: params[:query]).results.map(&:id)
      @users = User.with_ids(ids)
    end

    @users ||= User.active
    @users = @users.age_from(params[:age_from].to_i) if params[:age_from].present?
    @users = @users.age_to(params[:age_to].to_i) if params[:age_to].present?
    @users = @users.by_gender(params[:gender]) if params[:gender].present?
    @users = @users.includes(:user_conditions).by_condition(params[:condition_id]) if params[:condition_id].present? && params[:condition_id] != 'any'
    @users = @users.includes(:main_condition)
    @users = @users.with_photo if params[:with_photos_only].to_i == 1
    @users = @users.where(country_id: params[:country].to_i) unless params[:country].blank?
    @users = @users.where(state: params[:state]) unless params[:state].blank?

    if params[:last_signed_in].present?
      case params[:last_signed_in]
        when 'week'
          last_signed_in = 1.week.ago
        when 'six_months'
          last_signed_in = 6.month.ago
        when 'year'
          last_signed_in = 1.year.ago
        else
          last_signed_in = 1.month.ago
      end

      @users = @users.where('last_sign_in_at > ?', last_signed_in)
    end
    
    if params[:sort_by] =~ /patient_matches/
      filtered_user_ids = @users.pluck('users.id')
      
      @users = current_user.matching_users.where('users.id' => filtered_user_ids).order(params[:sort_by])
      
      @additional_users = User.where('users.id' => filtered_user_ids).where('users.id NOT IN (?)', @users.map(&:id)<<0).all
      @count = @users.pluck('count(distinct users.id)').first.to_i + @additional_users.count
      @users = @users + @additional_users
      @users = Kaminari.paginate_array(@users).page(params[:page]).per(20)
    else
      @users = @users.order(params[:sort_by]) if params[:sort_by].present?
      @count = @users.pluck('count(distinct users.id)').first
      @users = @users.page(params[:page]).per(20)
    end
  end

  def favorited_me
    @following_users = @user.following_users.page(params[:page]).per(20)
  end

  def my_favorites
    @followed_users = @user.followed_users.page(params[:page]).per(20)
  end

  def follow
    unless current_user.followed_users.where(followed_user: @user).present?
      current_user.follow!(@user)
    end
    respond_to do |format|
      format.html { redirect_to profile_path(@user.username), notice: "You have successfully added #{@user.username} to Favorites" }
      format.js
    end
  end

  def unfollow
    current_user.followed_users.where(followed_user: @user).delete_all
    @user.touch
    respond_to do |format|
      format.html { redirect_to profile_path(@user.username), notice: "You have successfully removed #{@user.username} from Favorites" }
      format.js
    end
  end

  def luv
    @user.luv!(current_user)

    respond_to do |format|
      format.html { redirect_to profile_path(@user.username), notice: "You have successfully sent #{@user.username} a LUV!" } 
      format.js
    end
  end

  def show
    render layout: false
  end

  def load_user
    @user = User.find(params[:id]) if params[:id].present?
  end

  def leaderboard
    params[:limit] ||= 100
    ignore_users = User.where(username: ['mojoey', 'frogger', 'carilea']).map(&:id)
    @top_users = User.where('users.id not in (?)', ignore_users).joins(:points).select('SUM(`action_point_users`.score) as total, users.*')
    case params[:sort]
      when 'highest_weekly'
        @top_users = @top_users.where('action_point_users.created_at > ?', 1.week.ago)
      when 'highest_monthly'
        @top_users = @top_users.where('action_point_users.created_at > ?', 1.month.ago)
    end
    @top_users = @top_users.group('users.id').order('total desc').limit(params[:limit])
  end

  def ranking
    @users = User.joins(:versions).where('(versions.item_type = "Treatment" || versions.item_type = "Symptom")')
    case params[:sort]
      when 'two_month'
        @users = @users.where('versions.created_at > ?', 2.months.ago)
      when 'one_month'
        @users = @users.where('versions.created_at > ?', 1.month.ago)
      when 'week'
        @users = @users.where('versions.created_at > ?', 1.week.ago)
    end
    @users = @users.group('users.id').select('count(*) as total_rank, users.username').order('total_rank desc')
  end

  def favorite_list
    @following_users = current_user.followed_users.page(params[:page]).per(20)
    respond_to do |format|
      format.js
      format.html
    end
  end

  def map
    params[:last_signed_in] ||= 'month'
    @users = User.with_coordinates
    @users = @users.age_from(params[:age_from].to_i) unless params[:age_from].blank?
    @users = @users.age_to(params[:age_to].to_i) unless params[:age_to].blank?
    @users = @users.by_gender(params[:gender]) unless params[:gender].blank?
    unless params[:condition_id].blank?
      @users = @users.includes(:user_conditions).by_condition(params[:condition_id])
      @users = @users.includes(:main_condition)
    end
    @users = @users.with_photo if params[:with_photos_only].to_i == 1
    @users = @users.where(country_id: params[:country].to_i) unless params[:country].blank?
    @users = @users.where(state: params[:state]) unless params[:state].blank?

    case params[:last_signed_in]
      when 'week'
        last_signed_in = 1.week.ago
      when 'six_months'
        last_signed_in = 6.month.ago
      when 'year'
        last_signed_in = 1.year.ago
      else
        last_signed_in = 1.month.ago
    end

    @users = @users.where('last_sign_in_at > ?', last_signed_in)
    respond_to do |f|
      f.html
      f.json
    end
  end

  def time_series_analysis
    params[:limit] ||= 10
    @users = User
      .joins(:versions)
      .where('versions.item_type' => %w(Treatment Symptom WellBeing))
      .where('versions.created_at > ?', 2.months.ago)
      .group('users.id')
      .select('count(*) as total_rank, users.*')
      .order('total_rank desc')
      .limit(params[:limit])
  end

  def time_series_analysis_admin
    params[:limit] ||= 1
    @users = User
      .joins(:versions)
      .where('versions.item_type' => %w(Treatment Symptom WellBeing))
      .where('versions.created_at > ?', 2.months.ago)
      .group('users.id')
      .select('count(*) as total_rank, users.*')
      .order('total_rank desc')
    @users = @users.where('users.username = ?', params[:username]) if params[:username].present?
    @users = @users.limit(params[:limit])
    render :time_series_analysis unless params[:username].present?
  end

end