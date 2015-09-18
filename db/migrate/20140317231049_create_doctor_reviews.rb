class CreateDoctorReviews < ActiveRecord::Migration
  def change
    create_table :doctor_reviews do |t|
      t.integer :doctor_id
      t.text :content

      t.timestamps
    end
  end
end
