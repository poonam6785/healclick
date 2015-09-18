class AddIsPublicToTreatment < ActiveRecord::Migration
  def change
    add_column :treatments, :is_public, :boolean
  end
end
