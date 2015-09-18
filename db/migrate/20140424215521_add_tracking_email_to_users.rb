class AddTrackingEmailToUsers < ActiveRecord::Migration
  def change
    add_column :users, :tracking_email, :integer, default: 1
  end
end
