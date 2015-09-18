class AddRankToTreatments < ActiveRecord::Migration
  def change
    add_column :treatments, :rank, :integer
  end

  def migrate direction
    super

    if direction == :up
      Treatment.reset_column_information
      User.find_each do |user|
        user.treatments.currently_taking_first.alphabetical.each_with_index do |treatment, rank|
          treatment.update_column(:rank, rank+1)
        end
      end
    end
  end
end
