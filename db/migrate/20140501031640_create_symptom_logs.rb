class CreateSymptomLogs < ActiveRecord::Migration
  def change
    create_table :symptom_logs do |t|
      t.references :symptom, index: true
      t.references :user, index: true
      t.date :date
      t.integer :numeric_level
      t.integer :rank

      t.timestamps
    end
  end
end
