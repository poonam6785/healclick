class AddMostHelpfulTreatmentIdToSymptoms < ActiveRecord::Migration
  def change
    add_column :symptoms, :most_helpful_treatment_id, :integer
  end
end
