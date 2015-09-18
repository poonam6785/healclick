class UpdateDoctorReviews < ActiveRecord::Migration
  def up
  	DoctorReview.find_each do |dr|
			dr.save rescue nil
  	end
  end

  def down
  	
  end
end
