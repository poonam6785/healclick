class CreateUserFollowers < ActiveRecord::Migration
  def change
    create_table :user_followers do |t|
      t.integer :followed_user_id
      t.integer :following_user_id

      t.timestamps
    end
  end
end
