class CreateLabs < ActiveRecord::Migration
  def change
    create_table :labs do |t|
      t.string :name
      t.integer :current_value
      t.string :unit
      t.integer :user_id

      t.timestamps
    end
  end
end
