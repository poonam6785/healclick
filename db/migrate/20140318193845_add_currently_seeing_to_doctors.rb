class AddCurrentlySeeingToDoctors < ActiveRecord::Migration
  def change
    add_column :doctors, :currently_seeing, :boolean
  end
end
