class AddIndececToActivityLog < ActiveRecord::Migration
  def change
    add_index :activity_logs, :favorite_user_id
  end
end
