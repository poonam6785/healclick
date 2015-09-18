class FixExistingSymptomSummaryNames < ActiveRecord::Migration
  def up
    SymptomSummary.find_each do |summary|
      summary.update_attributes(symptom_name: summary.symptom_name.strip.capitalize)
    end
  end
end
