class SymptomsController < ApplicationController

  before_filter :authenticate_user!, :find_symptom
  skip_before_filter :check_profile, :only => [:autocomplete, :create, :set_level, :set_period, :batch_create]

  def autocomplete
    if params[:query].length >= 3
      @symptoms = SymptomSummary.search(params[:query]).order('symptoms_count DESC').limit(8)
    else
      @symptoms = []
    end
    render json: @symptoms.map(&:with_frequency).compact.map(&:to_s).map(&:titleize).to_json
  end

  def create
    render text: 'ok' if symptom_params[:symptom].blank?
    @symptom = current_user.symptoms.new(symptom_params)
    unless @symptom.save
      @error = 'User condition could not be saved.'
      render 'errors/error.js'
    end
  end

  def update
    @symptom.update_attributes(symptom_params)
  end

  def batch_create
    @symptoms = []
    @errors = nil
    symptom_params[:symptom].split(',').each do |symptom|
      symptom = current_user.symptoms.create(symptom: symptom)
      @errors = symptom.errors.try(:[], :symptom).try(:first) if @errors.nil?
      @symptoms << symptom if symptom.valid?
    end
  end

  def batch_update
    current_user.update_attributes batch_symptom_params
    @desired_path = my_health_personal_profile_path(medical_editor: :symptoms)
    @finished = params[:finished] == 'true'
    @js_redirect = params[:commit] == "Track More Symptoms"
    respond_to do |format|
      format.html { redirect_to @desired_path }
      format.js
    end    
  end

  def batch_delete
    current_user.symptoms.where(id: params[:ids].split(',')).destroy_all
  end

  def popular_symptoms
    (Array.wrap(params[:popular_symptoms]) - current_user.symptoms.names).each do |symptom|
      current_user.symptoms.create symptom: symptom
    end
    current_user.update_attributes popular_symptoms_show: false
    redirect_to home_path
  end

  def set_level
    @symptom.update_attribute(:level, params[:level])
  end

  def set_period
    @symptom.update_attribute(:period, params[:period])
    render text: 'ok'
  end

  def destroy
    @symptom_name = @symptom.symptom
    @symptom.destroy
  end

  def find_symptom
    @symptom = current_user.symptoms.find(params[:id]) if params[:id].present?
  end

  def symptom_params
    params.require(:symptom).permit(:symptom, :numeric_level, :started_on, :ended_on, :most_helpful_treatment_id, :notify, :force_version_timestamp)
  end

  def batch_symptom_params
    now = Time.now.in_time_zone
    if params[:user][:symptoms_attributes].present?
      params[:user][:symptoms_attributes].each do |a|
        a[1][:tracking_date] = now
      end
    end
    if params[:user][:well_being_attributes].present?
      params[:user][:well_being_attributes][:tracking_date] = now
    end
    params.require(:user).permit({
      symptoms_attributes: [:id, :numeric_level, :most_helpful_treatment_id, :notify, :force_version_timestamp, :rank, :tracking_date],
      well_being_attributes: [:id, :numeric_level, :force_version_timestamp, :tracking_date]
    })
  end

end