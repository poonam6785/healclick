class AddLastInteractionAtToComments < ActiveRecord::Migration
  def change
    add_column :comments, :last_interaction_at, :datetime
  end
end
