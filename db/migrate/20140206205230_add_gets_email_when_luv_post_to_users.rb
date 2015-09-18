class AddGetsEmailWhenLuvPostToUsers < ActiveRecord::Migration
  def change
    add_column :users, :gets_email_when_luv_post, :boolean
  end
end
