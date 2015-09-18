class AddCountryToUsers < ActiveRecord::Migration
  def change
    add_column :users, :country_cache, :string
    User.where('country_id is not null').joins(:country).update_all 'users.country_cache=countries.name'
  end
end
