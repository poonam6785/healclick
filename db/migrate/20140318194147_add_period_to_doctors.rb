class AddPeriodToDoctors < ActiveRecord::Migration
  def change
    add_column :doctors, :started_on, :date
    add_column :doctors, :ended_on, :date
  end
end
