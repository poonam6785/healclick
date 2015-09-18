class CreateTreatments < ActiveRecord::Migration
  def change
    create_table :treatments do |t|
      t.string :treatment
      t.date :started_on
      t.date :ended_on
      t.integer :user_id
      t.string :result_level

      t.timestamps
    end
  end
end
