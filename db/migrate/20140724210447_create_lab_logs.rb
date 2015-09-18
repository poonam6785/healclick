class CreateLabLogs < ActiveRecord::Migration
  def change
    create_table :lab_logs do |t|
      t.integer :lab_id
      t.date :date
      t.string :current_value
      t.string :unit

      t.timestamps
    end
  end
end
