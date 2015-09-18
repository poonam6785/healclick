module ActivityLogged
  extend ActiveSupport::Concern

  included do
    has_many :activity_logs, as: :activity
  end

  module ActiveRecord
    def log_activity_on *events
      include ActivityLogged
      events.each do |cb|
        send(cb, :log_activity)
      end
    end
  end

  def log_activity
    ::ActivityLogger.new(self).notice_followed_users
  end

  def activity_attributes
    attrs = case self.class.name
      when 'Photo', 'CroppedPhoto'
        attributes.merge(attachment_url: self.attachment.url(:medium))
      else
        attributes
    end
    attrs.merge(class_name: self.class.name, username: self.user.try(:username)).symbolize_keys
  end
end