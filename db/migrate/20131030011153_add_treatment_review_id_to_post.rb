class AddTreatmentReviewIdToPost < ActiveRecord::Migration
  def change
    add_column :posts, :treatment_review_id, :integer
  end
end
