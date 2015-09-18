class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :title
      t.text :content
      t.integer :user_id
      t.integer :helpfuls_count
      t.integer :comments_count

      t.timestamps
    end
  end
end
