class ChangeLabLogColumType < ActiveRecord::Migration
  def change
    change_column :lab_logs, :current_value, :float
    change_column :labs, :current_value, :float
  end
end
