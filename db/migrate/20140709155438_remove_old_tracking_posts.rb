class RemoveOldTrackingPosts < ActiveRecord::Migration
  def change
    Post.where(tracking_update: true).destroy_all
  end
end
