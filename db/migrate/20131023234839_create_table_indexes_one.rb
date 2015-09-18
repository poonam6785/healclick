class CreateTableIndexesOne < ActiveRecord::Migration
  def change
    create_table :table_indexes_ones do |t|
      add_index :comments, :commentable_id
      add_index :comments, :commentable_type, length: 15
      add_index :comments, :parent_id
      add_index :comments, :user_id
      add_index :comments, :deleted
      add_index :helpfuls, :user_id
      add_index :helpfuls, :markable_id
      add_index :helpfuls, :markable_type, length: 15
      add_index :messages, :from_user_id
      add_index :messages, :to_user_id
      add_index :messages, :reply_to_message_id
      add_index :messages, :deleted_by_sender
      add_index :messages, :deleted_by_recipient
      add_index :messages, :is_read
      add_index :notifications, :from_user_id
      add_index :notifications, :to_user_id
      add_index :notifications, :notifiable_id
      add_index :notifications, :notifiable_type, length: 15
      add_index :notifications, :notification_type, length: 15
      add_index :notifications, :is_read
      add_index :patient_matches, :from_user_id
      add_index :patient_matches, :to_user_id
      add_index :photos, :post_id
      add_index :photos, :user_id
      add_index :post_followers, :user_id
      add_index :post_followers, :post_id
      add_index :posts, :user_id
      add_index :posts, :post_category_id
      add_index :symptoms, :user_id
      add_index :treatments, :user_id
      add_index :user_conditions, :user_id
      add_index :user_conditions, :condition_id
      add_index :user_followers, :followed_user_id
      add_index :user_followers, :following_user_id
      add_index :users, :main_condition_id
    end
  end
end
