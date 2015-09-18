class DropActionPointsTable < ActiveRecord::Migration
  def up
    drop_table :action_points
  end

  def down

  end
end
