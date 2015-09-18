class AddPrivacyToUsers < ActiveRecord::Migration
  def change
    add_column :users, :privacy, :integer, default: 1
  end
end
