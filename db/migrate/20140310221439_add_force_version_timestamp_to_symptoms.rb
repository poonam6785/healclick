class AddForceVersionTimestampToSymptoms < ActiveRecord::Migration
  def change
    add_column :symptoms, :force_version_timestamp, :datetime
  end
end
