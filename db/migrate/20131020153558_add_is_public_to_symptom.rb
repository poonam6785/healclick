class AddIsPublicToSymptom < ActiveRecord::Migration
  def change
    add_column :symptoms, :is_public, :boolean
  end
end
