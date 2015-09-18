module SymptomsHelper
  def user_symptoms_for_chart_filter user
    options = [['Select symptom', '']]
    return options if user.blank?
    options << [WellBeing::SYMPTOM]*2
    options << ['All Symptoms', user.symptoms.join('|')]
    options += user.symptoms.pluck(:symptom).map do |symptom|
      [symptom]*2
    end
    options_for_select options
  end

  def health_tracker_needs_tracking?
    desired_time = Symptom::NOTIFY_PERIOD.ago.to_i
    return false if current_user.settings.health_tracker_opened_at.to_i >= desired_time
    return false if current_user.well_being.try(:updated_at).to_i >= desired_time
    true
  end
end