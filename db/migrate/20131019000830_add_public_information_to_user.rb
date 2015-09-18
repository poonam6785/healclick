class AddPublicInformationToUser < ActiveRecord::Migration
  def change
    add_column :users, :profile_is_public, :boolean
    add_column :users, :photo_is_public, :boolean
    add_column :users, :age_is_public, :boolean
    add_column :users, :gender_is_public, :boolean
    add_column :users, :bio_is_public, :boolean
    add_column :users, :main_condition_is_public, :boolean
    add_column :users, :followed_users_is_public, :boolean
    add_column :users, :following_users_is_public, :boolean
  end
end
