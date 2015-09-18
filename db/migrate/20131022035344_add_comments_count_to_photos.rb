class AddCommentsCountToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :comments_count, :integer
  end
end
