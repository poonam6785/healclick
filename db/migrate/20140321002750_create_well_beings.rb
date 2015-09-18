class CreateWellBeings < ActiveRecord::Migration
  def change
    create_table :well_beings do |t|
      t.integer :user_id
      t.integer :numeric_level
      t.datetime :force_version_timestamp

      t.timestamps
    end
  end
end
