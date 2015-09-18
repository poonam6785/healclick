class TreatmentLog < ActiveRecord::Base
  belongs_to :treatment
  belongs_to :user

  after_save :handle_tracking_update

  private

  def handle_tracking_update
    if self.treatment.present? && (take_today_changed? || current_dose_changed? || level_changed?)
      routes = Rails.application.routes.url_helpers
      h = ActionController::Base.helpers
      treatments = self.treatment.treatment
      treatments += ", #{self.current_dose}" unless self.current_dose.blank?
      treatments += ", #{self.level.try(:humanize).try(:titleize)}" unless self.level.blank?
      treatments += " (#{h.link_to 'See My Review', routes.treatment_summary_review_path(self.treatment.treatment_summary, self.treatment.treatment_review.review)})" if self.treatment.treatment_review.present? && !self.treatment.treatment_review.content.blank?
      treatments += '<br>'
      post = self.user.posts.tracking_updates.where('created_at > ?', 1.day.ago).where('content LIKE ?', '%treatments%').first
      symptom_post = self.user.posts.tracking_updates.where('created_at > ?', 1.day.ago).where('content LIKE ?', '%symptoms!%')
      if symptom_post.any?
        track_target = 'symptoms and treatments'
      else
        track_target = 'treatments!'
      end
      if post.nil?
        self.user.posts.create title: 'Tracking Update', content: "#{user.username} just tracked their #{h.link_to(track_target, routes.profile_path(self.user.username))} Join the #{h.link_to('tracking party.', routes.my_health_personal_profile_path(medical_editor: :treatments, anchor: :treatments))} <br> #{treatments}", hide_for_feed: true, tracking_update: true
        symptom_post.destroy_all if symptom_post.any?
      else
        if !(post.content =~ /#{Regexp.escape(self.treatment.treatment)}/).nil?
          post.content = post.content.gsub /#{self.treatment.treatment}(.*)<br>/, treatments
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
end
