class Event < ActiveRecord::Base
  belongs_to :user

  validates :body, :presence => true
  validates :user_id, :presence => true

  before_save :populate_date

  default_scope order('events.date DESC, events.created_at DESC')

  has_paper_trail

protected
  def populate_date
    assign_attributes(date: Time.zone.now.to_date) if date.blank?
  end
end
