class AddExtraFieldsToPost < ActiveRecord::Migration
  def change
    add_column :posts, :interactions_count, :integer
    add_column :posts, :last_interaction_at, :datetime
  end
end
