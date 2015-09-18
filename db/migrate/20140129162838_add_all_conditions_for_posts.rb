class AddAllConditionsForPosts < ActiveRecord::Migration
  def change
    add_column :posts, :all_conditions, :boolean, default: false
  end
end
