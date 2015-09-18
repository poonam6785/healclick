class AddAddressInfoToUser < ActiveRecord::Migration
  def change
    add_column :users, :country_id, :integer
    add_column :users, :address, :string
    add_column :users, :address2, :string
    add_column :users, :city, :string
    add_column :users, :state, :string
    add_column :users, :zipcode, :string
  end
end
