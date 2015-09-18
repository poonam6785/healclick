class AddLastInteractionUserIdToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :last_interaction_user_id, :integer
    Post.reset_column_information
    Post.find_each(&:update_interactions_count!)
  end
end
