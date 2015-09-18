class Treatment < ActiveRecord::Base

  belongs_to :user
  belongs_to :condition
  belongs_to :treatment_summary, touch: true
  has_one :treatment_review, dependent: :destroy

  has_many :treatment_logs, dependent: :destroy

  after_create :create_review, unless: :skip_review_update
  after_create :reload_user
  after_save :update_review_title, if: :treatment_changed?
  after_save :update_timestamp, if: :current_dose_changed?
  after_save :update_timestamp, if: :level_changed?
  after_save :handle_tracking_update
  before_save :remove_ended_on, :load_numeric_level, :load_treatment_summary
  before_create :set_currently_taking
  before_validation :strip_treatment

  after_create :update_user_symptom_ranks
  after_destroy :update_user_symptom_ranks

  after_save :update_treatment_log

  attr_accessor :skip_review_update, :hide_for_feed, :tracking_date

  default_scope lambda{where("treatment <> '' and treatment is not null")}

  scope :recent, lambda{ order('created_at desc') }

  scope :alphabetical, -> { order('treatments.treatment ASC') }

  scope :search, lambda{ |query| where('lower(treatment) LIKE ?', "%#{query.to_s.downcase}%")}

  scope :with_review, lambda { joins(treatment_review: :review).where('numeric_level is not null and numeric_level > 0') }

  scope :currently_taking, -> { where(currently_taking: true) }
  scope :not_currently_taking, -> { where(currently_taking: false) }

  scope :currently_taking_first, -> {order('treatments.currently_taking DESC')}

  scope :by_rank, -> { order('treatments.rank ASC, treatments.id ASC') } #sort by rank asc, nulls first

  validates :treatment, uniqueness: {scope: :user_id, case_sensitive: false}, presence: true

  has_paper_trail

  TREATMENT_TYPES = ['Rx drug', 'OTC drug', 'Supplement', 'Herbal', 'Diet', 'Other']

  def to_s
    treatment.to_s
  end

  def reload_user
    user.save
  end

  def load_numeric_level
    case level
    when 'much_worse'
      self.numeric_level = 1
    when 'little_worse'
      self.numeric_level = 2
    when 'no_change'
      self.numeric_level = 3
    when 'little_better'
      self.numeric_level = 4
    when 'much_better'
      self.numeric_level = 5
    end
  end

  def self.reviews
    Post.where(treatment_review_id: TreatmentReview.where(treatment_id: scoped.pluck('treatments.id')))
  end

  def create_review
    TreatmentReview.create!(treatment: self, hide_for_feed: self.hide_for_feed)
    update_treatment_summary
  end

  def update_treatment_summary
    load_treatment_summary
    self.treatment_summary.reload_numbers
    self.treatment_summary.update_condition(self)
    self.treatment_summary.merge_summaries_with_same_treatment_name
  end

  def create_or_return_treatment_review
    if treatment_review.blank? || treatment_review.review.blank?
      treatment_review.try(:destroy)
      create_review
    end
    treatment_review
  end

  def load_treatment_summary
    if treatment_summary.blank?
      self.treatment_summary = TreatmentSummary.where(treatment_name: treatment).first_or_create
    end
  end

  def remove_ended_on
    self.ended_on = nil if self.currently_taking?
  end

  def update_review_title
    review = treatment_review.try(:review)
    review.update_attributes(title: "#{treatment} Review") if review.present?
  end

  def update_treatment_log
    date = tracking_date || updated_at.try(:to_date)
    treatment_log = treatment_logs.where(date: date, user_id: self.user_id).first_or_initialize
    treatment_log.update_attributes(treatment_log_attributes)
  end

  def handle_tracking_update
    if take_today_changed? || current_dose_changed? || level_changed?
      routes = Rails.application.routes.url_helpers
      h = ActionController::Base.helpers
      treatments = self.treatment
      treatments += ", #{self.current_dose}" unless self.current_dose.blank?
      treatments += ", #{self.level.try(:humanize).try(:titleize)}" unless self.level.blank?
      treatments += " (#{h.link_to 'See My Review', routes.treatment_summary_review_path(self.treatment_summary, self.treatment_review.review)})" if self.treatment_review.present? && !self.treatment_review.content.blank?
      treatments += '<br>'
      post = self.user.posts.tracking_updates.where('created_at > ?', 1.week.ago).where('content LIKE ?', '%treatments%').first
      symptom_post = self.user.posts.tracking_updates.where('created_at > ?', 1.week.ago).where('content LIKE ?', '%symptoms!%')
      if symptom_post.any?
        track_target = 'symptoms and treatments'
      else
        track_target = 'treatments!'
      end
      if post.nil?
        self.user.posts.create title: 'Tracking Update', content: "#{user.username} just tracked their #{h.link_to(track_target, routes.profile_path(self.user.username))} Join the #{h.link_to('tracking party.', routes.my_health_personal_profile_path(medical_editor: :treatments, anchor: :treatments))} <br> #{treatments}", hide_for_feed: true, tracking_update: true
        symptom_post.destroy_all if symptom_post.any?
      else
        if !(post.content =~ /#{Regexp.escape(self.treatment)}/).nil?
          post.content = post.content.gsub /#{Regexp.escape(self.treatment)}(.*)<br>/, treatments
        else
          post.content += treatments
        end
        if symptom_post.any?
          post.content = post.content.gsub /treatments!/, track_target
          symptom_post.destroy_all
        end
        post.save
        post.touch :created_at
      end
    end
  end

  private

  def strip_treatment
    self.treatment = self.treatment.strip
  end

  def set_currently_taking
    self.currently_taking = true
  end

  def update_user_symptom_ranks
    transaction do
      user.treatments.by_rank.each_with_index do |treatment, index|
        treatment.update_column :rank, index+1
      end
    end
  end

  def treatment_log_attributes
    attributes.symbolize_keys.slice(:level, :numeric_level, :currently_taking, :take_today, :current_dose, :rank)
  end

  def update_timestamp
    if treatment_review.present? && treatment_review.review.present?
      treatment_review.review.touch :created_at
      treatment_review.review.touch :last_interaction_at
    end
  end
end