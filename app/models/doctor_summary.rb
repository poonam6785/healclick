class DoctorSummary < ActiveRecord::Base
	has_many :doctors
	belongs_to :latest_review, class_name: "Review", foreign_key: 'latest_review_id'

	scope :search, lambda{ |query| where("lower(doctor_name) LIKE ?", "%#{query.to_s.downcase}%")}
	scope :with_reviews, lambda{ where("latest_review_id is not null") } 

  after_update :reload_numbers
  after_save :merge_summaries_with_same_doctor_name

	searchable do
    text :doctor_name
    text :doctor_review do
      doctors.each do |doctor|
      	doctor.doctor_review.content
      end
    end
    text :doctor_country_cache do
  		doctors.each do |doctor|
  			doctor.country_cache
  		end
    end	
    text :doctor_city do
  		doctors.each do |doctor|
  			doctor.city
  		end
    end	
    text :doctor_state do
  		doctors.each do |doctor|
  			doctor.state
  		end
    end	
    text :doctor_zipcode do
  		doctors.each do |doctor|
  			doctor.zipcode
  		end
    end	
  end

  def self.text_search(options = {})
    solr_search do
      fulltext options[:query]
    end
  end

	def reload_numbers
		doctor_review = doctors.joins(doctor_review: :review).where('posts.deleted_at is null and doctor_reviews.content is not null').order('posts.updated_at DESC').first.try(:doctor_review)
		reload_rating

		update_columns({
			reviews_count: doctors.with_review.where('posts.deleted_at is null').count,
			latest_review_id: doctor_review.try(:review).try(:id)
		})
		self
	end

	def self.names_with_counts
    pluck(:doctor_name, :reviews_count).map do |row|
      "#{row.first} (#{row.last})"
    end
  end

  def reload_rating
		positives = doctors.where(recommended: true).size
		negatives = doctors.where(recommended: false).size
		total = positives + negatives
		rating = positives / total.to_f * 100 unless total == 0
		update_columns rating: rating
  end	


  def positives_rating
    doctors.where(recommended: true).size
  end

  def total_recommended
    doctors.where('recommended is not null').size
  end

protected
  def merge_summaries_with_same_doctor_name
    summaries = DoctorSummary.where('lower(trim(doctor_name)) = ?', doctor_name.to_s.strip.downcase)
    if summaries.count > 1
      doctor_ids = summaries.map(&:doctor_ids).flatten.uniq
      Doctor.where(id: doctor_ids).update_all(doctor_summary_id: self.id)
      summaries.reject {|s| s.id == self.id}.map(&:destroy)
    end
    touch
    reload.reload_numbers
  end
end
