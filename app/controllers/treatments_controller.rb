class TreatmentsController < ApplicationController

  before_filter :authenticate_user!, :find_treatment, :find_tracking_date
  skip_before_filter :check_profile, :only => [:autocomplete, :create, :set_level, :set_period, :batch_create]

  def autocomplete
    if params[:query].length >= 3
      @treatments = TreatmentSummary.search(params[:query]).where('reviews_count > 0').order('reviews_count DESC')
    else
      @treatments = []
    end

    render json: @treatments.try(:names_with_counts)
  end

  def create
    render text: 'ok' if treatment_params[:treatment].blank?

    @treatment = current_user.treatments.new(treatment_params)
    unless @treatment.save
      @error = 'User condition could not be saved.'
      render 'errors/error.js'
    end
  end

  def edit
  end

  def update
    @treatment.update_attributes(treatment_params)
  end

  def batch_create
    @errors = nil
    @treatments = []
    @date = Date.parse(params.fetch(:date, Time.zone.now.to_date.to_s)) unless params[:date].blank?
    treatment_params[:treatment].split(',').reverse.each do |treatment|
      treatment = Treatment.new treatment: treatment, user_id: current_user.id, skip_review_update: true
      if treatment.valid?
        treatment[:user_id] = current_user.id
        treatment.save
        @treatments << treatment
      else
        @errors = treatment.errors.try(:[], :treatment).try(:first) if @errors.nil?
      end
    end
  end

  def batch_update
    if @tracking_date.today?
      current_user.update_attributes batch_treatment_params
    else
      batch_treatment_params[:treatments_attributes].values.each do |attrs|
        treatment = current_user.treatments.find attrs[:id]
        treatment.update_attributes attrs
        treatment.update_treatment_log
      end
    end
    @desired_path = my_health_personal_profile_path(medical_editor: :treatments)
    @finished = params[:finished] == 'true'
    @js_redirect = params[:commit] == "Track More Treatments"
    respond_to do |format|
      format.html { redirect_to @desired_path }
      format.js { render 'symptoms/batch_update' }
    end    
  end

  def batch_delete
    params[:ids].split(',').each do |id|
      treatment = Treatment.find_by_id(id)
      summary = treatment.treatment_summary
      treatment.destroy
      summary.reload_numbers
    end
  end

  def set_level
    if @treatment.treatment_review.nil?
      @treatment.hide_for_feed = true
      @treatment.create_review
    end
    @treatment.update_attributes(level: params[:level])
    @treatment.update_treatment_summary
  end

  def set_period
    @treatment.update_attributes(period: params[:period])
    @treatment.update_treatment_summary
    render text: 'ok'
  end

  def set_type
    @treatment.update_attributes treatment_type: params[:type]
    render text: 'ok'
  end

  def destroy
    summary = @treatment.treatment_summary
    @treatment.destroy
    @treatment_id = @treatment.id
    summary.reload_numbers
  end

  def find_treatment
    @treatment = current_user.treatments.find(params[:id]) if params[:id].present?
  end

  def treatment_params
    params.require(:treatment).permit(:treatment, :level, :condition_id, :treatment_type, :currently_taking)
  end

  def batch_treatment_params
    prms = params.require(:user).permit(treatments_attributes: [:id, :take_today, :current_dose, :rank, :currently_taking])
    prms[:treatments_attributes].each do |key, attrs|
      attrs[:last_taken_at] = @tracking_date if attrs[:take_today] == '1'
      attrs[:tracking_date] = @tracking_date
    end
    prms
  end

  def find_tracking_date
    @tracking_date = Date.parse(params.fetch(:tracking_date, Time.zone.now.to_date.to_s))
    @date = @tracking_date
  end

end