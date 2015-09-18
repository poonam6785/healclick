class AddLocationfieldsToDoctors < ActiveRecord::Migration
  def change
    add_column :doctors, :country_id, :integer
    add_column :doctors, :country_cache, :string
    add_column :doctors, :state, :string
    add_column :doctors, :city, :string
    add_column :doctors, :zipcode, :string

    add_index :doctors, :country_id
  end
end
