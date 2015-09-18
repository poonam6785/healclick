class CreatePatientMatches < ActiveRecord::Migration
  def change
    create_table :patient_matches do |t|
      t.integer :score
      t.integer :from_user_id
      t.integer :to_user_id

      t.timestamps
    end
  end
end
