class AddIndexFortraetmentsReviews < ActiveRecord::Migration
  def change
    add_index :treatment_reviews, :treatment_id
  end
end
