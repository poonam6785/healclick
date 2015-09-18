class AddUpdatedTreatmentLogsToUser < ActiveRecord::Migration
  def change
    add_column :users, :update_treatment_logs, :boolean, default: false
  end
end
