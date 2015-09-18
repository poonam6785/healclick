class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :user_id
      t.integer :commentable_id
      t.string  :commentable_type
      t.integer :parent_id
      t.text    :content
      t.integer :comments_count
      t.integer :helpfuls_count

      t.timestamps
    end
  end
end