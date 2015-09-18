class CalculateSymptomsSummariesConditions < ActiveRecord::Migration
  def up
    SymptomSummaryCondition.destroy_all
    User.find_each do |user|
      next if user.main_condition_id.blank?
      user.symptoms.each do |symptom|
        ssc = SymptomSummaryCondition.where(condition_id: user.main_condition_id, symptom: symptom.symptom).first
        ssc = SymptomSummaryCondition.create condition_id: user.main_condition_id, symptom: symptom.symptom if ssc.nil?
        ssc.increment! :symptoms_count
      end
    end
  end

  def down

  end
end
