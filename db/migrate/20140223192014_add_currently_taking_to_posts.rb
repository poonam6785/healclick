class AddCurrentlyTakingToPosts < ActiveRecord::Migration
  def change
    add_column :treatments, :currently_taking, :boolean, default: false
  end
end
