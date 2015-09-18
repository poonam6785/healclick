class AddTreatmentTypeToTreatments < ActiveRecord::Migration
  def change
    add_column :treatments, :treatment_type, :string
  end
end
