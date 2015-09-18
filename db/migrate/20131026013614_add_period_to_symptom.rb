class AddPeriodToSymptom < ActiveRecord::Migration
  def change
    add_column :symptoms, :period, :string
  end
end
