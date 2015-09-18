class AddEmailDeliveredToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :email_delivered, :boolean, default: false
  end
end
