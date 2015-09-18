class TreatmentSummary < ActiveRecord::Base
	has_many :treatments
	has_many :treatment_reviews, through: :treatments
  has_many :treatment_summary_redirects

	has_and_belongs_to_many :conditions
	belongs_to :latest_review, class_name: 'Review', foreign_key: 'latest_review_id'

	scope :with_reviews, lambda{ where('latest_review_id is not null') }
  scope :for_conditions, lambda{ |condition_ids| joins(:conditions).where('conditions.id' => condition_ids) }
	scope :for_treatment, lambda{ |treatment_name| joins(treatment_reviews: [:review]).where("lower(treatment_name) like ? or lower(posts.title) like ?", "%#{treatment_name.to_s.downcase}%", "%#{treatment_name.to_s.downcase}%") }
  scope :search, lambda{ |query| where("lower(treatment_name) LIKE ?", "%#{query.to_s.downcase}%")}
  # We need live count of posts for passed condition, feel free to improove it. It needs at summaries page (http://stackoverflow.com/questions/23860695/mysql-group-by-twice-and-count)
  scope :for_summary_page, lambda { |condition_id, order, query| find_by_sql ["SELECT *, COUNT(id) as rcount, AVG(numeric_level) as average_level FROM (SELECT treatment_summaries.*, treatments.numeric_level FROM `treatment_summaries`
    	INNER JOIN `posts` ON `posts`.`id` = `treatment_summaries`.`latest_review_id` AND `posts`.`type` IN ('Review') AND `posts`.`deleted_at` IS NULL AND `posts`.`type` IN ('Review') AND (posts.deleted = false || posts.deleted is null)
    	INNER JOIN `treatments` ON `treatments`.`treatment_summary_id` = `treatment_summaries`.`id` AND (treatment <> '' and treatment is not null)
    	INNER JOIN `treatment_reviews` ON `treatment_reviews`.`treatment_id` = `treatments`.`id`
    	INNER JOIN `conditions_treatment_reviews` ON `conditions_treatment_reviews`.`treatment_review_id` = `treatment_reviews`.`id`
    	INNER JOIN `conditions` ON `conditions`.`id` = `conditions_treatment_reviews`.`condition_id`
    	INNER JOIN `conditions_treatment_summaries` `conditions_treatment_summaries_join` ON `conditions_treatment_summaries_join`.`treatment_summary_id` = `treatment_summaries`.`id`
    	INNER JOIN `conditions` `conditions_treatment_summaries` ON `conditions_treatment_summaries`.`id` = `conditions_treatment_summaries_join`.`condition_id`
    	WHERE
    		#{'`conditions`.`id` IN (' + condition_id +') AND' if condition_id != 'any'}
    		(lower(treatments.treatment) LIKE ? or lower(treatment_name) like ?) AND
    		(latest_review_id is not null) AND
    		treatments.numeric_level > 0
    	GROUP BY treatment_reviews.id ORDER BY posts.created_at desc) as t
  		GROUP BY id
  		#{'HAVING rcount > 5' if order == 'average_level desc'}
  		ORDER BY #{(order == 'rcount desc' || order == 'average_level desc') ? order : ActiveRecord::Base::sanitize(order)}", query, query]  }

	after_create :merge_summaries_with_same_treatment_name

  def to_param
    "#{treatment_name} #{id}".parameterize
  end

  def self.from_param(param)
    find_by_id! param.split('-').last
  end

	def reload_numbers
		treatment_review = treatments.joins(treatment_review: :review).where('posts.deleted is null and treatment_reviews.content is not null').order('posts.updated_at DESC').first.try(:treatment_review)

		update_columns({
			reviews_count: treatments.with_review.where('posts.deleted is null').count,
			review_average: treatments.with_review.where('posts.deleted is null').map(&:numeric_level).map(&:to_f).average,
			latest_review_id: treatment_review.try(:review).try(:id)
		})
		self
	end
  handle_asynchronously :reload_numbers, queue: :ongoing_jobs

	def update_condition(treatment)
		return unless treatment.treatment_review.present?

		treatment.treatment_review.conditions.each do |condition|
			if condition.treatment_reviews.count >= 0 && !conditions.include?(condition)
				self.conditions << condition
			end
		end

		save
	end
  handle_asynchronously :update_condition, queue: :ongoing_jobs

	def reload_conditions
		self.conditions = treatment_reviews.map(&:conditions).flatten.uniq
	end

	def reload_conditions!
		(treatment_reviews.map(&:conditions).flatten.uniq - conditions).each do |condition|
			condition.treatment_summaries << self
			condition.save #so we don't trigger callback loop
		end
	end

	def average_result
		if 4.0 <= review_average && review_average <= 5.0
			"Much Better"
		elsif 3.0 <= review_average && review_average < 4.0
			"Somewhat Better"
		elsif 2.0 <= review_average && review_average < 3.0
			"No Change"
		elsif 1.0 <= review_average && review_average < 2.0
			"Somewhat Worse"
		elsif 0.0 <= review_average && review_average < 1.0
			"Much Worse"
		end
	end

	def latest_written_review
		treatment_reviews.order('treatment_reviews.created_at DESC').reject do |review|
			review.content.blank?
		end.first
  end

  def self.to_csv_with_conditions
    CSV.generate(col_sep: ';') do |csv|
      csv << %w(Name Average\ effectiveness Reviews Conditions)
      TreatmentSummary.find_each do |summary|
        summary.conditions.each do |condition|
          treatment_reviews = summary.treatment_reviews.includes(:conditions).where(conditions: {id: condition.id}).where("numeric_level is not null and numeric_level > 0")
          reviews_count = treatment_reviews.size
          average = treatment_reviews.map{|tr| tr.treatment.numeric_level }.map(&:to_f).average
          csv << [summary.treatment_name, average, reviews_count, condition.name]
        end
      end
    end
  end

  def self.names_with_counts
    pluck(:treatment_name, :reviews_count).map do |row|
      "#{row.first} (#{row.last})"
    end
  end

	def merge_summaries_with_same_treatment_name  
		summaries = TreatmentSummary.where('lower(trim(treatment_name)) = ?', treatment_name.to_s.strip.downcase)
		if summaries.count > 1
			treatment_ids = summaries.map(&:treatment_ids).flatten.uniq
			Treatment.where(id: treatment_ids).update_all(treatment_summary_id: self.id)            
			summaries.reject {|s| s.id == self.id}.map(&:destroy)
		end    
		touch
		reload_conditions!
		reload_numbers
	end

	def post_count_by_condition(user, condition = 'any')
		return self.treatments.joins(treatment_review: :review).where('posts.deleted is null').where('(treatment_reviews.content IS NOT NULL) OR (treatments.level IS NOT NULL)').count if condition == 'any'
		Post.where(treatment_review_id: self.treatment_reviews.map(&:id)).by_treatment_condition(condition, user).joins(treatment_review: :treatment).where('numeric_level > 0').length
	end

	def live_average(condition = 'any', user)
		Post.where(treatment_review_id: self.treatment_reviews.map(&:id)).by_treatment_condition(condition, user).select('*').joins(treatment_review: :treatment).where('numeric_level > 0').map(&:numeric_level).map(&:to_f).average.to_f
	end
end