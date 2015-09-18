class AddTreatmentLevelToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :treatment_level, :integer
  end
end
