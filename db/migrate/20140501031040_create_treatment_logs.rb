class CreateTreatmentLogs < ActiveRecord::Migration
  def change
    create_table :treatment_logs do |t|
      t.references :treatment, index: true
      t.references :user, index: true
      t.date :date
      t.integer :numeric_level
      t.boolean :currently_taking
      t.boolean :take_today
      t.string :current_dose
      t.integer :rank

      t.timestamps
    end
  end
end
