class AddActivityPostIdToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :activity_post_id, :integer
    add_index :posts, :activity_post_id
  end
end