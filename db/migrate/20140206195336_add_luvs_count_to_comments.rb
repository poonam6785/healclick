class AddLuvsCountToComments < ActiveRecord::Migration
  def change
    add_column :comments, :luvs_count, :integer
  end
end
