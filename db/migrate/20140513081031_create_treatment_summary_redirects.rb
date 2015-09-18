class CreateTreatmentSummaryRedirects < ActiveRecord::Migration
  def change
    create_table :treatment_summary_redirects do |t|
      t.integer :treatment_summary_id
      t.string :old_link

      t.timestamps
    end
  end
end
