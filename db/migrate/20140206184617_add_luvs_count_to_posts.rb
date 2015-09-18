class AddLuvsCountToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :luvs_count, :integer
  end
end
