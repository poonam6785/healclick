class AddDoctorReviewIdToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :doctor_review_id, :integer
    add_index :posts, :doctor_review_id
  end
end
