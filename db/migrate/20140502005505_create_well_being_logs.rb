class CreateWellBeingLogs < ActiveRecord::Migration
  def change
    create_table :well_being_logs do |t|
      t.references :well_being, index: true
      t.date :date
      t.integer :numeric_level

      t.timestamps
    end
  end
end
