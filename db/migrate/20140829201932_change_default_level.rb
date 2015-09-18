class ChangeDefaultLevel < ActiveRecord::Migration
  def change
    change_column_default :treatments, :level, ''
    change_column_default :treatment_logs, :level, ''
  end
end
