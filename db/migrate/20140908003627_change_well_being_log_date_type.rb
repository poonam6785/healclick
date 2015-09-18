class ChangeWellBeingLogDateType < ActiveRecord::Migration
  def change
    change_column :well_being_logs, :date, :datetime
  end
end
