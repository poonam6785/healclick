class ChangeTreatmentsDefaults < ActiveRecord::Migration
  def change
    change_column_default :treatments, :take_today, false
    change_column_default :treatment_logs, :take_today, false
    change_column_default :treatments, :current_dose, ''
    change_column_default :treatment_logs, :current_dose, ''
  end
end
