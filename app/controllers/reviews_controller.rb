class ReviewsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :redirect_to_correct

  before_filter :authenticate_user!, except: [:summary, :index]
  before_filter :load_review_objects, only: [:summary, :index]
  before_filter :find_treatment_summaries_or_redirect, only: [:index]

  def new
    if params[:treatment_id].present?
      @treatment = current_user.treatments.find(params[:treatment_id])
    else
      @doctor = current_user.doctors.find(params[:doctor_id])
      @remote = true
    end
  end

  def summary
    if params[:condition_id].present?
      if current_user
        current_user.settings.condition_id = params[:condition_id]
      else
        session[:condition_id] = params[:condition_id]
      end
    end
    params[:condition_id] = view_context.get_cached_condition_id
    params[:sort_by] ||= 'treatment_summaries.created_at desc'
    conditions = ''
    if params[:condition_id] != 'any'
      conditions = params[:condition_id] == 'my_conditions' ? [current_user.main_condition.try(:id)] + current_user.user_conditions.map(&:condition_id) : [Condition.find_by_slug(params[:condition_id]).try(:id)]
      conditions.compact!
    end

    @condition_id = view_context.get_cached_condition_id == 'my_conditions' ? view_context.get_cached_condition_id : Condition.find_by_slug(view_context.get_cached_condition_id).try(:id)
    @condition_id = conditions.join(',') if view_context.get_cached_condition_id == 'my_conditions'
    @condition_id ||= 'any'

    query = "%#{params[:query]}%".downcase
    @summaries = TreatmentSummary.for_summary_page(@condition_id.to_s, params[:sort_by], query)
    @summaries = Kaminari.paginate_array(@summaries).page(params[:page]).per(10)
    if current_user
      @doctor_review = DoctorReview.new
      @doctor_review.doctor = current_user.doctors.new
    end
  end

  def index
    return redirect_to url_for(params.except(:condition_id)) if params[:condition_id].present?
    params[:sort_by] ||= 'posts.last_interaction_at desc'
    params[:review_condition_id] ||= 'any'

    @treatments = Treatment.where('lower(treatments.treatment) like ?', "%#{params[:treatment_name].to_s.downcase}%") if params[:treatment_name].present?

    if @treatments.present? && params[:treatment_name].blank? && @treatments.count == 1
      params[:treatment_name] = @treatments.first.treatment
    end

    @posts = @treatments.reviews if @treatments.present?
    @posts = Review.valid
    sort_by = params[:sort_by]
    @posts = @posts.joins(:user).order(sort_by.gsub('patient_matches.score desc,', ''))
    unless params[:titles_search].blank?
      ids = Post.search do
        fulltext params[:titles_search] do
          fields(:title)
        end
      end.results.map(&:id)
      @posts = @posts.with_ids(ids)
    end
    unless params[:by_member_search].blank?
      ids = Post.search do
        fulltext params[:by_member_search] do
          fields(:username)
        end
      end.results.map(&:id)
      @posts = @posts.with_ids(ids)
    end
    unless params[:desease_tag_search].blank?
      conditions = params[:desease_tag_search].split ','
      @posts = @posts.joins(treatment_review: :conditions).where('conditions.name IN (?)', conditions)
      @posts = @posts.having('COUNT(DISTINCT conditions_treatment_reviews.condition_id) = ?', conditions.size) if conditions.size > 1
    end
    @posts = @posts.with_user_matching(current_user) if params[:sort_by] =~ /score/
    @posts = @posts.by_treatments(@treatment_summaries) if @treatment_summaries.present?
    @posts = @posts.by_treatment_condition(params[:review_condition_id], current_user) if params[:review_condition_id] != 'any'
    @posts = @posts.group("posts.id")
    @posts = @posts.page(params[:page]).per(20)

    if current_user
      @doctor_review = DoctorReview.new
      @doctor_review.doctor = current_user.doctors.new
    end

  end

  def destroy
    @post = Review.find(params[:id])
    @post_id = @post.id
    @summary = @post.treatment_review.try(:treatment).try(:treatment_summary)
    @post.delete!
    if @summary.present?
      @summary.reload_numbers
    end

    respond_to do |format|
      format.html { redirect_to reviews_path, notice: 'Review successfully removed' }
      format.js { render 'destroy.js' }
    end
  end

  def edit
    review = Review.from_param params[:id]
    @treatment_review = review.treatment_review
    @treatment = @treatment_review.treatment
    @remote = true
  end

  def load_review_objects
    @treatment_review = TreatmentReview.new
    @treatment_review.treatment = Treatment.new(period: "#{1.month.ago.strftime("%m-%Y")} - Current", user: current_user, skip_review_update: true)
    @comment = Comment.new
  end

  def interest
    @post = Review.find(params[:id])
    @comment = Comment.new
    current_user.interested!(@post)
  end

  def old_routes
    redirect_to_correct
  end

  private

  # /treatment_summaries/2567-d-ribose/reviews  => /treatment_summaries/d-ribose-2567/reviews
  def redirect_to_correct
    if params[:treatment_summary_id].present?
      redirect_to treatment_summary_reviews_path(TreatmentSummary.from_param(params[:treatment_summary_id])), status: :moved_permanently
    end
  end

  protected
  def find_treatment_summaries_or_redirect
    if params[:treatment_summary_id].present?
      @treatment_summaries = [TreatmentSummary.from_param(params[:treatment_summary_id])]
      if @treatment_summaries.compact.empty?
        @treatment_redirect = TreatmentSummaryRedirect.find_by_old_link(params[:treatment_summary_id])
        if @treatment_redirect.present?
          redirect_to treatment_summary_reviews_path(@treatment_redirect.treatment_summary) and return false
        end
      end
    end
  end
end
