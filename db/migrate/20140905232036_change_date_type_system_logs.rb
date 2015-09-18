class ChangeDateTypeSystemLogs < ActiveRecord::Migration
  def change
    change_column :symptom_logs, :date, :datetime
  end
end
