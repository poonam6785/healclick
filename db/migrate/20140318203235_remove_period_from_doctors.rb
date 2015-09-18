class RemovePeriodFromDoctors < ActiveRecord::Migration
  def change
  	remove_column :doctors, :period
  end
end
