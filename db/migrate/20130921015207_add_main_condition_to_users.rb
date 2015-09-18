class AddMainConditionToUsers < ActiveRecord::Migration
  def change
    add_column :users, :main_condition_id, :integer
  end
end
