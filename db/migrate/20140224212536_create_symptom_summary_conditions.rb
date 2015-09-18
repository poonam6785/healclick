class CreateSymptomSummaryConditions < ActiveRecord::Migration
  def change
    create_table :symptom_summary_conditions do |t|
      t.string :symptom
      t.integer :condition_id
      t.integer :symptoms_count

      t.timestamps
    end
  end
end
