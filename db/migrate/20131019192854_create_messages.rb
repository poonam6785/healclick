class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :old_id
      t.integer :from_user_id
      t.integer :to_user_id
      t.integer :reply_to_message_id
      t.string :subject
      t.text :content
      t.boolean :deleted_by_sender
      t.boolean :deleted_by_recipient
      t.boolean :is_read

      t.timestamps
    end
  end
end
