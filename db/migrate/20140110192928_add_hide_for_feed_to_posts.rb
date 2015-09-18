class AddHideForFeedToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :hide_for_feed, :boolean, default: false
  end
end
