class CreatePostFollowers < ActiveRecord::Migration
  def change
    create_table :post_followers do |t|
      t.integer :post_id
      t.integer :user_id

      t.timestamps
    end
  end
end
