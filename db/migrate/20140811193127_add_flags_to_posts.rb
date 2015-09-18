class AddFlagsToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :flags, :integer, null: false, default: 0
  end
end
