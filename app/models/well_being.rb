class WellBeing < ActiveRecord::Base
  has_paper_trail

  belongs_to :user
  has_many :well_being_logs
  after_save :update_well_being_log
  after_save :handle_tracking_update if :numeric_level_changed?

  LEVELS = %w(happy smiley neutral sad angry)
  SYMPTOM = 'Overall Well-Being'

  attr_accessor :tracking_date

  #methods for compatibility with symptoms in chart

  def symptom
    WellBeing::SYMPTOM
  end

  def unified_level
    numeric_level
  end

  def update_well_being_log
    date = tracking_date || updated_at
    well_being_log = well_being_logs.build
    well_being_log.update_attributes(well_being_log_attributes.merge(date: date))
  end

private

  def well_being_log_attributes
    attributes.symbolize_keys.slice(:numeric_level)
  end

  def handle_tracking_update
    routes = Rails.application.routes.url_helpers
    h = ActionController::Base.helpers
    posts = self.user.posts.tracking_updates.where('created_at > ?', 1.week.ago).where('content LIKE ?', '%symptoms!%')
    if posts.any?
      posts.delete_all(['id != ?', posts.last.try(:id)]) if posts.size > 1
      posts.map {|p| p.touch :created_at}
      posts.map {|p| p.touch :updated_at}
    else
      self.user.posts.create title: 'Tracking Update', hide_for_feed: true, content: "#{self.user.username} just tracked their #{h.link_to('symptoms!', routes.profile_path(self.user.username))} Join the #{h.link_to('tracking party.', routes.my_health_personal_profile_path(medical_editor: :symptoms, anchor: :medical_editor))}", tracking_update: true
    end
  end
end
