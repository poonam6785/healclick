class CreateDoctorSummaries < ActiveRecord::Migration
  def change
    create_table :doctor_summaries do |t|
      t.string :doctor_name
      t.string :reviews_count
      t.string :latest_review_id

      t.timestamps
    end
  end
end
