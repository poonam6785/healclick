class ChangeColumnTypeForTitle < ActiveRecord::Migration
  def change
    change_column :activity_logs, :title, :text
  end
end
