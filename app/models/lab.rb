class Lab < ActiveRecord::Base
  has_paper_trail
  attr_accessor :date

  belongs_to :user
  belongs_to :lab_summary, counter_cache: true
  has_many :lab_logs, dependent: :destroy

  validates :name, presence: true
  validates :current_value, numericality: true, allow_blank: true

  after_save :handle_logs
  before_create :assign_summary

  def self.find_max_current_value(lab_user)
    LabLog.where(lab_id: lab_user.labs.map(&:id)).order('current_value DESC').first.try(:current_value).try(:to_i)
  end

  private

  def assign_summary
    self.lab_summary = LabSummary.find_or_create_by lab: self.name
  end

  def handle_logs
    if lab_logs.where(date: date).any?
      lab_logs.where(date: date).update_all current_value: current_value, unit: unit
    else
      lab_logs.create date: date, current_value: current_value, unit: unit
    end
  end
end