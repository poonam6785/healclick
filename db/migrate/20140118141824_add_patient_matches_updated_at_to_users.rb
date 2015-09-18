class AddPatientMatchesUpdatedAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :patient_matches_updated_at, :datetime
  end
end
