class AddConditionIdToTreatment < ActiveRecord::Migration
  def change
    add_column :treatments, :condition_id, :integer
  end
end
