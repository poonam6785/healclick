class TreatmentReviewsController < ApplicationController

  before_filter :authenticate_user!, :load_treatment

  def autocomplete
    if params[:query].length >= 3
      @summaries = TreatmentSummary.search(params[:query]).order('reviews_count DESC')
    else
      @summaries = []
    end

    render json: @summaries.try(:names_with_counts)
  end

  def create
    treatment_attrs = treatment_review_params[:treatment_attributes].except(:id, :user_id)
    if @treatment.blank?
      @treatment = current_user.treatments.find_by_treatment treatment_review_params[:treatment_attributes].try(:[], :treatment)
      @treatment = current_user.treatments.create(treatment_attrs) if @treatment.blank?
    else
      @treatment.update_attributes(treatment_attrs)
    end
    @treatment_review = TreatmentReview.new(treatment_review_params.except(:treatment_attributes).merge(treatment: @treatment))

    # Only one treatment_review per treatment. Update if already exist
    if @treatment.treatment_review.nil?
      if @treatment_review.save
        @treatment_review.treatment.update_attributes treatment_attrs unless treatment_attrs.nil?
        @treatment_review.treatment.treatment_summary.reload_numbers
        @treatment_review.treatment.treatment_summary.update_condition(@treatment_review.treatment)
      end
    else

      @treatment.update_attributes treatment_attrs unless treatment_attrs.nil?
      @treatment_review = @treatment.treatment_review
    end

    if params[:treatment_id].present?
      redirect_to my_health_personal_profile_path(medical_editor: :treatments), notice: "Review for treatment successfully created"
    else
      @comment = Comment.new
      respond_to do |f|
        f.html {redirect_to everything_path(condition_id: current_user.settings.condition_id), notice: "Review for treatment successfully created"}
        f.js
      end
    end
  end

  def update
    @treatment_review = TreatmentReview.find(params[:id])
    @date = Date.parse(params[:date].blank? ? Time.zone.now.to_date.to_s : params[:date])
    if @treatment_review.update_attributes(treatment_review_params)
      @treatment_review.review.update_attributes(hide_for_feed: false)
      @treatment_review.treatment.treatment_summary.reload_numbers
      @treatment_review.treatment.treatment_summary.update_condition(@treatment_review.treatment)
      respond_to do |f|
        f.html {redirect_to my_health_personal_profile_path(medical_editor: :treatments), notice: "Review for treatment successfully updated"}
        f.js {
          @comment = Comment.new
        }
      end
    end
  end

  def check_unique_name
    exists = current_user.treatments.exists? treatment: params[:treatment]
    render json: {exists: exists}
  end

  def load_treatment
    @treatment = current_user.treatments.find(params[:treatment_id]) if params[:treatment_id].present?
  end

  def treatment_review_params
    params.require(:treatment_review).permit(:content, condition_ids: [], treatment_attributes: [:id, :treatment, :level, :treatment_type, :period, :user_id, :skip_review_update, :currently_taking, :started_on, :ended_on, :current_dose, review_attributes: [:hide_for_feed]])
  end

end