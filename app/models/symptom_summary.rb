class SymptomSummary < ActiveRecord::Base
  has_many :symptoms
  has_many :users, through: :symptoms
  belongs_to :sub_category

  scope :search, lambda{ |query| where("lower(symptom_name) LIKE ?", "%#{query.to_s.downcase}%")}
  scope :popular, -> {order('symptoms_count DESC').limit(20)}
  scope :popular_names, -> {popular.pluck('LOWER(TRIM(symptom_summaries.symptom_name)) as symptom_name').uniq}

  after_create :merge_summaries_with_same_symptom_name

  def with_frequency
    "#{symptom_name} (#{self.try(:symptoms_count)})"
  end

  def merge_summaries_with_same_symptom_name
    summaries = SymptomSummary.where('lower(trim(symptom_name)) = ?', symptom_name.to_s.strip.downcase)
    if summaries.count > 1
      symptom_ids = summaries.map(&:symptom_ids).flatten.uniq
      Symptom.where(id: symptom_ids).update_all(symptom_summary_id: self.id)
      summaries.reject {|s| s.id == self.id}.map(&:destroy)
      SymptomSummary.reset_counters(self.id, :symptoms)
    end
  end

  def name
    symptom_name
  end
end
