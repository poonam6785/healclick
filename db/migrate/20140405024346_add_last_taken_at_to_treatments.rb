class AddLastTakenAtToTreatments < ActiveRecord::Migration
  def change
    add_column :treatments, :last_taken_at, :datetime
  end
end
