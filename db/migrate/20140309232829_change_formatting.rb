class ChangeFormatting < ActiveRecord::Migration
  def up
    Notification.where(notification_type: 'COMMENTED_ON_REPLY').update_all 'content = REPLACE(content, "on your reply on", "to your reply")'
  end

  def down

  end
end
