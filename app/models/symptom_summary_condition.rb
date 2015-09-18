class SymptomSummaryCondition < ActiveRecord::Base
  belongs_to :condition

  scope :popular_for_condition, ->(condition_id) {where(condition_id: condition_id).order('symptoms_count DESC').limit(20)}
end
