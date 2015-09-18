class TreatmentSummaryRedirect < ActiveRecord::Base
  belongs_to :treatment_summary

  validates :treatment_summary_id, :old_link, presence: true
end
