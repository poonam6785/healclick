class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.text :body
      t.integer :user_id

      t.timestamps
    end
  end
end
