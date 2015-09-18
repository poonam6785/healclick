class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :from_user_id
      t.integer :to_user_id
      t.integer :notifiable_id
      t.string :notifiable_type
      t.string :notification_type
      t.text :content
      t.boolean :is_read
      t.timestamps
    end
  end
end
