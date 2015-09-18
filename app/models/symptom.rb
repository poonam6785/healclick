class Symptom < ActiveRecord::Base
  SCALE = 0..10
  GRADES = %w(none worst)
  NOTIFY_PERIOD = 24.hours

  LEVELS = {
    minimal: 2,
    mild: 4,
    moderate: 6,
    severe: 8,
    extreme: 10
  }

  attr_accessor :tracking_date

  belongs_to :user, touch: true
  belongs_to :symptom_summary, counter_cache: true

  belongs_to :most_helpful_treatment, class_name: 'Treatment'

  has_many :symptom_logs

  before_save :set_summary
  before_validation :strip_symptom

  after_create :update_user_symptom_ranks
  after_save :handle_tracking_update
  after_destroy :update_user_symptom_ranks

  after_save :update_symptom_log

  scope :search, lambda{ |query| where('lower(symptom) LIKE ?', "%#{query.to_s.downcase}%")}

  default_scope { where("symptom <> '' and symptom is not null") }

  scope :recent, -> { order('symptoms.created_at desc') }
  scope :recently_updated, -> { order('symptoms.updated_at desc') }
  scope :notify, -> { where(notify: true) }
  scope :not_notify, -> { where(notify: false) }
  scope :notify_first, -> { order('symptoms.notify DESC, symptoms.created_at DESC') }
  scope :by_rank, -> { order('-symptoms.rank DESC') } #sort by rank asc, nulls last

  scope :top, ->(count) {
    joins(:symptom_summary).order('symptom_summaries.symptoms_count DESC').limit(count)
  }

  validates :symptom, uniqueness: {scope: :user_id, case_sensitive: false}, on: :create
  has_paper_trail

  def to_s
    symptom
  end

  def self.names
    pluck('symptoms.symptom')
  end

  def reload_user
    user.try(:save)
  end

  def with_frequency
    "#{symptom} (#{self.try(:frequency)})"
  end

  def set_summary
    return if symptom_summary.present?
    summary = SymptomSummary.find_or_create_by_symptom_name self.symptom
    self.symptom_summary = summary
  end

  def unified_level
    numeric_level || LEVELS[level.to_s.downcase.to_sym]
  end

  def update_symptom_log
    date = tracking_date || updated_at
    symptom_log = symptom_logs.build
    symptom_log.update_attributes(symptom_log_attributes.merge(date: date))
  end

private

  def strip_symptom
    self.symptom = self.symptom.strip
  end

  def update_user_symptom_ranks
    transaction do
      user.symptoms.by_rank.each_with_index do |symptom, index|
        symptom.update_column :rank, index+1
      end
    end
  end

  def symptom_log_attributes
    attributes.symbolize_keys.slice(:numeric_level, :rank)
  end

  def handle_tracking_update
    routes = Rails.application.routes.url_helpers
    h = ActionController::Base.helpers
    posts = self.user.posts.tracking_updates.where('created_at > ?', 1.week.ago).where('content LIKE ?', '%symptoms!%')
    treatment_post = self.user.posts.tracking_updates.where('created_at > ?', 1.week.ago).where('content LIKE ? OR content LIKE ?', '%treatments%', '%symptoms and treatments%').first
    if treatment_post.nil?
      track_target = 'symptoms!'
    else
      track_target = 'symptoms and treatments'
    end
    if posts.any?
      posts.delete_all(['id != ?', posts.last.try(:id)]) if posts.size > 1
      if treatment_post.nil?
        posts.map {|p| p.touch :created_at}
        posts.map {|p| p.touch :updated_at}
      else
        treatment_post.content = treatment_post.content.gsub /treatments!/, track_target
        treatment_post.touch :created_at
        treatment_post.touch :updated_at
        treatment_post.save
        posts.destroy_all
      end
    elsif treatment_post.present?
      treatment_post.content = treatment_post.content.gsub /treatments!/, track_target
      treatment_post.touch :created_at
      treatment_post.touch :updated_at
      treatment_post.save
    end

    self.user.posts.create title: 'Tracking Update', hide_for_feed: true, content: "#{self.user.username} just tracked their #{h.link_to(track_target, routes.profile_path(self.user.username))} Join the #{h.link_to('tracking party.', routes.my_health_personal_profile_path(medical_editor: :symptoms, anchor: :medical_editor))}", tracking_update: true if !posts.any? && treatment_post.nil?
  end
end