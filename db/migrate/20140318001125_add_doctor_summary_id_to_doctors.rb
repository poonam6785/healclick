class AddDoctorSummaryIdToDoctors < ActiveRecord::Migration
  def change
    add_column :doctors, :doctor_summary_id, :integer
  end
end
