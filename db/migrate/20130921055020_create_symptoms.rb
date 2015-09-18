class CreateSymptoms < ActiveRecord::Migration
  def change
    create_table :symptoms do |t|
      t.string :symptom
      t.string :level
      t.integer :user_id

      t.timestamps
    end
  end
end
