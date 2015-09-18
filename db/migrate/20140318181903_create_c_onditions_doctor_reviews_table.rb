class CreateCOnditionsDoctorReviewsTable < ActiveRecord::Migration
  def change
    create_table :conditions_doctor_reviews, id: false do |t|
      t.integer :condition_id
      t.integer :doctor_review_id
    end
    add_index :conditions_doctor_reviews, :condition_id
    add_index :conditions_doctor_reviews, :doctor_review_id
  end
end
