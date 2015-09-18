class AddEmailSettingsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :gets_email_for_private_message, :boolean, default: true
    add_column :users, :gets_email_for_follower, :boolean, default: true
    add_column :users, :gets_email_for_helpful, :boolean, default: true
    add_column :users, :gets_email_when_mentioned, :boolean, default: true
    add_column :users, :gets_email_when_reply, :boolean, default: true
    add_column :users, :gets_email_when_comment, :boolean, default: true
    add_column :users, :gets_email_when_luv, :boolean, default: true
    add_column :users, :gets_email_when_subscribed, :boolean, default: true
  end
end
