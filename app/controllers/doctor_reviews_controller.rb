class DoctorReviewsController < ApplicationController

  before_filter :authenticate_user!, only: [:create, :update]

  def new
    
  end

  def index
    params[:sort_by] ||= 'doctor_summaries.updated_at desc'
    if current_user
      @doctor_review = DoctorReview.new
      @doctor_review.doctor = current_user.doctors.new 
    end
    @summaries = if params[:query].present?
      ids = DoctorSummary.text_search(query: params[:query]).results.map(&:id)
      DoctorSummary.where(id: ids)
    else
      DoctorSummary
    end.with_reviews.page(params[:page]).per(20)
    @summaries = @summaries.joins(:doctors).where('doctors.country_id = ?', params[:country_id]) if params[:country_id].present?
    @summaries = @summaries.joins(:doctors).where('doctors.state = ?', params[:state]) if params[:state].present?
    if params[:condition_id] == 'my_conditions'
      @summaries = @summaries.joins(doctors: {doctor_review: :conditions}).where('conditions_doctor_reviews.condition_id IN(?)', ([current_user.main_condition.try(:id)] + current_user.user_conditions.map(&:condition_id)).join(','))
    else
      @summaries = @summaries.joins(doctors: {doctor_review: :conditions}).where('conditions_doctor_reviews.condition_id = ?', Condition.find_by_slug(params[:condition_id]).try(:id)) if params[:condition_id].present? && params[:condition_id] != 'any'
    end
    @summaries = @summaries.order(params[:sort_by])
    @summaries = @summaries.group("doctor_summaries.id")

    @treatment_review = TreatmentReview.new
    @treatment_review.treatment = Treatment.new(period: "#{1.month.ago.strftime("%m-%Y")} - Current", user: current_user, skip_review_update: true)
  end

  def summary
    params[:sort_by] ||= "posts.last_interaction_at desc"
    if current_user
      @doctor_review = DoctorReview.new
      @doctor_review.doctor = current_user.doctors.new 
    end
    @doctor_summary = DoctorSummary.find(params[:doctor_summary_id])

    @posts = @doctor_summary.doctors.reviews.joins(:user).order(params[:sort_by])
    @posts = @posts.with_user_matching(current_user) if params[:sort_by] =~ /score/
    @posts = @posts.page(params[:page]).per(20)
    @comment = Comment.new
    @treatment_review = TreatmentReview.new
    @treatment_review.treatment = Treatment.new(period: "#{1.month.ago.strftime("%m-%Y")} - Current", user: current_user, skip_review_update: true)
  end

  def create
    doctor_attrs = doctor_review_params[:doctor_attributes].except(:id, :user_id)
    if @doctor.blank?
      @doctor = current_user.doctors.find_by_name doctor_review_params[:doctor_attributes].try(:[], :name)
      @doctor = current_user.doctors.create(doctor_attrs) if @doctor.blank?
    else
      @doctor.update_attributes(doctor_attrs)
    end
    @doctor_review = DoctorReview.new(doctor_review_params.except(:doctor_attributes).merge(doctor: @doctor))

    # Only one doctor_review per doctor. Update if already exist
    if @doctor.doctor_review.nil?
      if @doctor_review.save
        @doctor_review.doctor.update_attributes doctor_attrs unless doctor_attrs.nil?
      end
    else

      @doctor.update_attributes doctor_attrs unless doctor_attrs.nil?
      @doctor_review = @doctor.doctor_review
    end
    @doctor_review.doctor.doctor_summary.reload_numbers
    @comment = Comment.new
    respond_to do |f|
      f.html {redirect_to summary_doctor_reviews_path(doctor_summary_id: @doctor.doctor_summary.try(:id)), notice: "Review for doctor successfully created"}
      f.js
    end
  end

  def edit
    review = Review.from_param params[:id]
    @doctor = review.doctor_review.try(:doctor)
    @remote = true
  end

  def update
    @doctor_review = DoctorReview.find(params[:id])
    if @doctor_review.update_attributes(doctor_review_params)
      @doctor_review.review.update_attributes(hide_for_feed: false)
      @doctor_review.doctor.doctor_summary.reload_numbers
      # @doctor_review.doctor.doctor_summary.update_condition(@doctor_review.doctor)
    end
    @doctor = @doctor_review.doctor
    @post = @doctor_review.review
  end

  def check_unique_name
    exists = current_user.doctors.exists? name: params[:doctor]
    render json: {exists: exists}
  end

  def load_doctor
    @doctor = current_user.doctors.find(params[:doctor_id]) if params[:doctor_id].present?
  end

  def doctor_review_params
    params.require(:doctor_review).permit(:content, condition_ids: [], doctor_attributes: [:id, :name, :user_id, :skip_review_update, :currently_seeing, :started_on, :ended_on, :city, :state, :country_id, :zipcode, :recommended, review_attributes: [:hide_for_feed]])
  end

end