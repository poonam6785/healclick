class AddCommentIdToNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :comment_id, :integer
  end
end
