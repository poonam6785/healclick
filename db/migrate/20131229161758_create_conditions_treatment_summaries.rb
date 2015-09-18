class CreateConditionsTreatmentSummaries < ActiveRecord::Migration
  def change
    create_table :conditions_treatment_summaries, id: false do |t|
      t.references :condition
      t.references :treatment_summary
    end
  end
end
