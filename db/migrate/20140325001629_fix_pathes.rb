class FixPathes < ActiveRecord::Migration
  def up
  	ActivityLog.where(activity_type: 'Comment').update_all 'title = REPLACE(title, "/reviews/", "/posts/")'
  end

  def down

  end
end
