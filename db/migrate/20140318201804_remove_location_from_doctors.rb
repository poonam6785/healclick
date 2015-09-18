class RemoveLocationFromDoctors < ActiveRecord::Migration
  def change
  	remove_column :doctors, :location
  end
end
