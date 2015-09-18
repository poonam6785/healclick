class CreateUserConditions < ActiveRecord::Migration
  def change
    create_table :user_conditions do |t|
      t.integer :user_id
      t.integer :condition_id

      t.timestamps
    end
  end
end
