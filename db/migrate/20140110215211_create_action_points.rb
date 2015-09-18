class CreateActionPoints < ActiveRecord::Migration
  def change
    create_table :action_points do |t|
      t.string :name
      t.integer :points_per_action

      t.timestamps
    end
  end
end
