class AddActionableTypeAndActionableIdToActionPoinUsers < ActiveRecord::Migration
  def change
    add_column :action_point_users, :actionable_type, :string
    add_column :action_point_users, :actionable_id, :integer
  end
end
