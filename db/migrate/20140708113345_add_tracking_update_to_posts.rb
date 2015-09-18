class AddTrackingUpdateToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :tracking_update, :boolean, default: false
    add_index :posts, :tracking_update
  end
end
