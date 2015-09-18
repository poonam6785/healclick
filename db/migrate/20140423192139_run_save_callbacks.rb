class RunSaveCallbacks < ActiveRecord::Migration
  def up

  	TreatmentReview.where('created_at > ?', 3.months.ago).each do |tr|
	  	begin
				tr.run_callbacks(:save)
	  	rescue Exception => e
	  	end
		end
  end

  def down
  	
  end
end
