class AddExtraFieldsToTreatments < ActiveRecord::Migration
  def change
    add_column :treatments, :level, :string
    add_column :treatments, :period, :string
  end
end
