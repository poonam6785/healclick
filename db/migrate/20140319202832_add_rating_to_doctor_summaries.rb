class AddRatingToDoctorSummaries < ActiveRecord::Migration
  def change
    add_column :doctor_summaries, :rating, :float
  end
end
