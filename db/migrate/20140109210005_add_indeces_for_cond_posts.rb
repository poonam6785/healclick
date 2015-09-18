class AddIndecesForCondPosts < ActiveRecord::Migration
  def change
    Post.transaction do
      add_index :conditions_posts, :condition_id
      add_index :conditions_posts, :post_id
    end
  end
end
