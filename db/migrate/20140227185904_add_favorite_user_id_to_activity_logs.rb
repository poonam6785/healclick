class AddFavoriteUserIdToActivityLogs < ActiveRecord::Migration
  def change
    add_column :activity_logs, :favorite_user_id, :integer
  end
end
