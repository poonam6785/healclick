class AddNumericLevelToSymptoms < ActiveRecord::Migration
  def up
    add_column :symptoms, :numeric_level, :integer

    levels = {
      minimal: 2,
      mild: 4,
      moderate: 6,
      severe: 8,
      extreme: 10
    }
    Symptom.reset_column_information
    Symptom.find_each do |symptom|
      next if symptom.level.blank?
      symptom.update_column(:numeric_level, levels[symptom.level.to_s.downcase.to_sym])
    end

  end

  def down
    remove_column :symptoms, :numeric_level
  end
end
