class AddOldIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :old_id, :integer
  end
end
