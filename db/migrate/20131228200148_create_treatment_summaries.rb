class CreateTreatmentSummaries < ActiveRecord::Migration
  def change
    create_table :treatment_summaries do |t|
      t.string :treatment_name
      t.integer :reviews_count
      t.integer :latest_review_id
      t.decimal :review_average, scale: 2, precision: 8

      t.timestamps
    end
  end
end