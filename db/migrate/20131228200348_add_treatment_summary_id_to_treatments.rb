class AddTreatmentSummaryIdToTreatments < ActiveRecord::Migration
  def change
    add_column :treatments, :treatment_summary_id, :integer
  end
end
