class AddBannedInfoToUsers < ActiveRecord::Migration
  def change
    add_column :users, :banned_reason, :text
    add_column :users, :full_banned, :boolean
    add_column :users, :post_banned, :boolean
    add_column :users, :login_banned, :boolean
    add_column :users, :registration_banned, :boolean
  end
end
