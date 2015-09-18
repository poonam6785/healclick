class AddCommentIdToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :comment_id, :integer
    add_index :posts, :comment_id
  end
end
