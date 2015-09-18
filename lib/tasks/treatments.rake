namespace :treatments do 

	task load_all: :environment do
		Treatment.all.each do |t|
			puts "Treatment: #{t.treatment}"
			summary = TreatmentSummary.find_by_treatment_name(t.treatment.to_s.downcase.titleize)			
			if summary.blank?
				puts "Created!"
				summary = TreatmentSummary.create!(treatment_name: t.treatment.to_s.downcase.titleize)
			else
				puts "Existing!"
			end

			t.treatment_summary = summary
			t.save
		end
	end

end