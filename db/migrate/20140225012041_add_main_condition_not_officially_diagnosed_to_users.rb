class AddMainConditionNotOfficiallyDiagnosedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :main_condition_not_officially_diagnosed, :boolean
  end
end
