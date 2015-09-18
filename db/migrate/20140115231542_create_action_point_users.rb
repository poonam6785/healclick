class CreateActionPointUsers < ActiveRecord::Migration
  def change
    create_table :action_point_users do |t|
      t.integer :user_id
      t.string :action
      t.integer :score

      t.timestamps
    end
  end
end
