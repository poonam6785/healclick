class AddNotifyToSymptoms < ActiveRecord::Migration
  def change
    add_column :symptoms, :notify, :boolean
  end
end
