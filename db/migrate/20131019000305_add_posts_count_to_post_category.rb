class AddPostsCountToPostCategory < ActiveRecord::Migration
  def change
    add_column :post_categories, :posts_count, :integer
  end
end
