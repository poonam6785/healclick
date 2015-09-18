class AddAnonymousToActivityLog < ActiveRecord::Migration
  def change
    add_column :activity_logs, :anonymous, :boolean
  end
end
