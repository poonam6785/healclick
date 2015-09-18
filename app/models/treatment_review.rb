class TreatmentReview < ActiveRecord::Base

  has_and_belongs_to_many :conditions
  belongs_to :treatment, touch: true
  has_one :review, dependent: :destroy

  accepts_nested_attributes_for :treatment
  attr_accessor :hide_for_feed

  before_save :check_conditions
  after_save :update_review
  after_save :update_timestamp, if: :content_changed?
  after_save :handle_tracking_update, if: :content_changed?

  def create_review
    self.hide_for_feed = false if self.hide_for_feed.nil?
    if self.review.blank?
      self.review = Review.create!(treatment_review: self,
                                   user: treatment.try(:user),
                                   title: "#{treatment.try(:treatment)} Review",
                                   content: content,
                                   hide_for_feed: self.hide_for_feed)
    end
  end

  def update_review
    create_review
    self.review.update_attributes(treatment_level: treatment.try(:numeric_level), title: "#{treatment.try(:treatment)} Review", content: self.content)
  end

  def check_conditions
    if conditions.blank? && treatment.user.present? && treatment.user.main_condition.present?
      self.conditions << treatment.user.main_condition
    end
  end

  private

  def update_timestamp
    review.touch :created_at
    review.touch :last_interaction_at
  end

  def handle_tracking_update
    self.treatment.handle_tracking_update
  end

end