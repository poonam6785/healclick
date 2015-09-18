class AddLockedToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :locked, :boolean
  end
end
