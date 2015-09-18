class AddEmailDigestToUser < ActiveRecord::Migration
  def up
    add_column :users, :email_digest_when_comment_after, :boolean, default: false
    add_column :users, :email_digest_when_luv, :boolean, default: false
    add_column :users, :email_digest_when_luv_post, :boolean, default: false
    add_column :users, :email_digest_when_subscribed, :boolean, default: false
    add_column :users, :email_digest_for_private_message, :boolean, default: false
    add_column :users, :email_digest_for_follower, :boolean, default: false
    add_column :users, :email_digest_for_helpful, :boolean, default: false
    add_column :users, :email_digest_when_mentioned, :boolean, default: false
    add_column :users, :email_digest_when_reply, :boolean, default: false
    add_column :users, :email_digest_when_comment, :boolean, default: false
  end
end
