class AddStartedOnEndedOnToSymptoms < ActiveRecord::Migration
  def change
    add_column :symptoms, :started_on, :date
    add_column :symptoms, :ended_on, :date
  end
end
