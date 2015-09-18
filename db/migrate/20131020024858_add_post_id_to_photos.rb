class AddPostIdToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :post_id, :integer
  end
end
