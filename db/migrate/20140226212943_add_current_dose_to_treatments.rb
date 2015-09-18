class AddCurrentDoseToTreatments < ActiveRecord::Migration
  def change
    add_column :treatments, :current_dose, :string
  end
end
