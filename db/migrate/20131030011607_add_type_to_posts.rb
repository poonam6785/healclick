class AddTypeToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :type, :string, default: "Post"
  end
end
