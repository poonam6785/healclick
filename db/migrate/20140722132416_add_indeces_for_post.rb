class AddIndecesForPost < ActiveRecord::Migration
  def change
    add_index :posts, :anonymous
    add_index :posts, :treatment_review_id
    add_index :posts, :type
    add_index :posts, :hide_for_feed
    add_index :posts, :last_interaction_user_id
  end
end
