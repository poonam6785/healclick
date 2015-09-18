class PostsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :redirect_to_correct

  before_action :redirect_to_review, only: [:show]
  before_action :redirect_to_landing, except: [:show, :post_body]
  before_action :set_post
  skip_before_filter :verify_authenticity_token

  # GET /posts
  # GET /posts.json
  def index
    params[:sort_by] ||= "posts.last_interaction_at desc"

    @posts = current_user.posts
    if params[:query].present?
      ids = Post.text_search(query: params[:query]).results.map(&:id)
      @posts = @posts.with_ids(ids)
    end
    @posts = @posts.topics.order(params[:sort_by]).page(params[:page]).per(20)
    @posts = @posts.with_user_condition if params[:sort_by] =~ /conditions/
    @posts = @posts.with_user_matching(current_user) if params[:sort_by] =~ /score/
    @posts = @posts.search(params[:query]) if params[:query].present?
    @posts = @posts.by_category(params[:post_category_id]) if params[:post_category_id].present?
    @post     = current_user.posts.new
    @comment  = Comment.new
  end

  def say_something
    @post = Post.new
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    if current_user.nil? && (@post.user.privacy == 3 || PostCategory.not_for_guests.map(&:id).include?(@post.post_category_id))
      redirect_to landing_path, alert: 'You must be logged in to do that' 
      return
    end
    @comment = Comment.new
    @treatment_review = TreatmentReview.new
    @treatment_review.treatment = Treatment.new(period: "#{1.month.ago.strftime("%m-%Y")} - Current", user: current_user, skip_review_update: true)
    if current_user
      @doctor_review = DoctorReview.new
      @doctor_review.doctor = current_user.doctors.new 
    end
    @post.view!
  end

  def post_body
    @content = @post.content.blank? ? @post.try(:treatment_review).try(:content) : @post.content
    @post.view!
  end

  # GET /posts/new
  def new
    @post = current_user.posts.new
  end

  # GET /posts/1/edit
  def edit
    respond_to do |format|
      format.html
      format.js { @remote = true }
    end
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = current_user.posts.new(post_params)
    respond_to do |format|
      if @post.save
        format.html { redirect_to everything_path(condition_id: current_user.settings.condition_id), notice: 'Post was successfully created.' }
      else
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    @comment = Comment.new
    if post_params[:condition_ids].present?
      if post_params[:condition_ids].delete('my_conditions')
        post_params[:condition_ids].concat(Array.wrap(current_user.main_condition_id) + current_user.conditions.map(&:id))
      end
      post_params[:condition_ids].compact!
    end
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.js { render 'update.js' }
      else
        format.html { render action: 'edit' }
        format.js { render 'update.js' }
      end
    end
  end

  def mark_as_helpful
    helpfuls = @post.helpfuls.where(user_id: current_user.id)
    if helpfuls.count > 0
      helpfuls.map(&:destroy)
    else
      @post.helpfuls.create!(user: current_user)
    end

    @post.reload
    respond_to do |format|
      format.js { render 'mark_as_helpful.js' }
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    post_type = @post.type
    @post_id = @post.id
    @post.destroy
    respond_to do |format|
      format.html { redirect_to root_path, notice: 'Post was successfully deleted' }
      format.js { render 'destroy.js' }
    end
  end

  def follow
    current_user.follow_post!(@post)
    @post.reload
    respond_to do |format|
      format.html {redirect_to view_context.post_review_path_helper(@post), notice: "You are now following this post"}
      format.js {@comment = Comment.new}
    end
  end

  def unfollow
    current_user.unfollow_post!(@post)
    @post.reload
    respond_to do |format|
      format.html {redirect_to view_context.post_review_path_helper(@post), notice: "You stopped following this post"}
      format.js {@comment = Comment.new}
    end
  end

  def luv
    if (@luvs = @post.luvs.where(:user_id => current_user.id)).present?
      @luvs.destroy_all
    else
      current_user.luv_post!(@post)
    end
    respond_to do |format|
      format.html { redirect_to view_context.post_review_path_helper(@post), notice: "You have successfully luved this post" }
      format.js
    end
  end

  def expand_replies
    @parent_post = Post.find @post.activity_post_id
    @comment = Comment.new
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      if %w(show mark_as_helpful follow unfollow post_body luv expand_replies).include?(params[:action])
        @post = Post.with_deleted.from_param(params[:id]) if params[:id].present?
        redirect_to treatment_summary_reviews_path(@post.treatment_review.treatment.treatment_summary) if @post.destroyed? && @post.type == 'Review'
        redirect_to medical_topics_path if @post.destroyed? && @post.type == 'Post'
      else
        if current_user.is_admin
          @post = Post.from_param(params[:id]) if params[:id].present?
        else
          @post = current_user.posts.from_param(params[:id]) if params[:id].present?
        end
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
      post_params ||= @post_params
      unless post_params
        if params[:post][:condition_ids].include?('all_conditions')
          params[:post][:condition_ids] = Condition.active.where('name is not null && name <> ""').order('name asc').map(&:id)
          params[:post][:all_conditions] = true
        else
          params[:post][:all_conditions] = false
        end
        post_params = params.require(:post).permit(:title, :content, :user_id, :helpfuls_count, :comments_count, :anonymous, :post_category_id, :picture, :all_conditions, :condition_ids => []).symbolize_keys
        if post_params[:condition_ids].present?
          if post_params[:condition_ids].delete('my_conditions')
            post_params[:condition_ids].concat(Array.wrap(current_user.main_condition_id) + current_user.conditions.map(&:id))
          end
          post_params[:condition_ids].compact!
        end
      end
      @post_params = post_params
    end

    def render_post_header
      if params[:action] == "show" && params[:controller] == "posts"
        true
      else
        false
      end
    end

    def redirect_to_correct
      if params[:id].present?
        post = Post.find_by_id(params[:id])
        if post.present?
          redirect_to view_context.post_review_path_helper(post), status: :moved_permanently
        else
          redirect_to everything_path
        end
      end
    end

    # Redirect old /posts/:id to /treatments/:treatment_summary_id:/reviews/:post_id
    def redirect_to_review
      post = Post.find_by_id params[:id]
      post = Post.from_param params[:id] unless post
      redirect_to view_context.post_review_path_helper(post), status: :moved_permanently if post && post.type == 'Review' && ((post.treatment_review_id.present? && params[:treatment_summary_id].blank?) || (post.doctor_review_id.present? && params[:doctor_summary_id].blank?))
    end
end
