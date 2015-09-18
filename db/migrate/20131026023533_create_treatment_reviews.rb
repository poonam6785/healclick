class CreateTreatmentReviews < ActiveRecord::Migration
  def change
    create_table :treatment_reviews do |t|
      t.integer :treatment_id
      t.text :content

      t.timestamps
    end
  end
end
