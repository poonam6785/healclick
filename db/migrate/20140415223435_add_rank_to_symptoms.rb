class AddRankToSymptoms < ActiveRecord::Migration
  def change
    add_column :symptoms, :rank, :integer
  end

  def migrate direction
    super

    if direction == :up
      Symptom.reset_column_information
      User.find_each do |user|
        symptoms_attributes = user.symptoms.recent.notify_first.each_with_index do |symptom, rank|
          symptom.update_column(:rank, rank+1)
        end
      end
    end
  end
end