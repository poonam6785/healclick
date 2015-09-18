class AddEmailSettingToUser < ActiveRecord::Migration
  def change
    add_column :users, :gets_email_when_comment_after, :boolean, default: true
  end
end
