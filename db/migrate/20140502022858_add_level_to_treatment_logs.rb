class AddLevelToTreatmentLogs < ActiveRecord::Migration
  def change
    add_column :treatment_logs, :level, :string
  end
end
