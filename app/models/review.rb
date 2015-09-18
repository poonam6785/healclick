class Review < Post

  belongs_to :treatment_review
  belongs_to :doctor_review
  after_save :add_points
  after_save :change_treatment_name, if: Proc.new { self.treatment_review.present? }
  after_save :change_doctor_name, if: Proc.new { self.doctor_review.present? }

  scope :valid, lambda {
    joins(treatment_review: :treatment).
    where('(treatment_reviews.content IS NOT NULL) OR (treatments.level IS NOT NULL)')
  }

  scope :with_written_review, ->{where('posts.content is not null && posts.treatment_level is not null && hide_for_feed = 0')}

  private

  def add_points
    if self.content_changed? && self.content_was.blank?
      unless self.user.points.exists?(action: 'written_treatment_reviews', actionable_type: 'Review', actionable_id: self.id)
        self.user.points.create action: 'written_treatment_reviews', score: ActionPoints.written_treatment_reviews, actionable_type: 'Review', actionable_id: self.id
      end
    end
  end

  def change_treatment_name
    if title_changed? && self.treatment_review.treatment.present?
      self.treatment_review.treatment.update_attributes treatment: self.title.try(:gsub, ' Review', '')
    end
  end

  def change_doctor_name
    if title_changed? && self.doctor_review.doctor.present?
      self.doctor_review.doctor.update_attributes name: self.title.try(:gsub, ' Review', '')
    end
  end

end