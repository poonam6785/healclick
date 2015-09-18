class DoctorReview < ActiveRecord::Base

  has_and_belongs_to_many :conditions
  belongs_to :doctor, touch: true
  has_one :review, dependent: :destroy

  accepts_nested_attributes_for :doctor
  attr_accessor :hide_for_feed

  before_save :check_conditions
  after_save :update_review

  def create_review
    self.hide_for_feed = false if self.hide_for_feed.nil?
    if self.review.blank?
      self.review = Review.create!(doctor_review: self,
                                   user: doctor.user,
                                   title: "#{doctor.name} Review",
                                   content: content,
                                   hide_for_feed: self.hide_for_feed)
    end
  end

  def update_review
    create_review
    self.review.update_attributes(title: "#{doctor.name} Review", content: self.content)
  end

  def check_conditions
    if conditions.blank? && doctor.user.present? && doctor.user.main_condition.present?
      self.conditions << doctor.user.main_condition
    end
  end

end