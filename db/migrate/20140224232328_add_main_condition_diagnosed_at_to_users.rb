class AddMainConditionDiagnosedAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :main_condition_diagnosed_at, :datetime
  end
end
