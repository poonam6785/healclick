class CreateActivityLogs < ActiveRecord::Migration
  def change
    create_table :activity_logs do |t|
      t.integer :user_id
      t.integer :activity_id
      t.string :title
      t.string :activity_type

      t.timestamps
    end
  end
end
