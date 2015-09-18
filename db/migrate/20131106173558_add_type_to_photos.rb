class AddTypeToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :type, :string
  end
end
