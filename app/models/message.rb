class Message < ActiveRecord::Base

  belongs_to :from_user, class_name: 'User'
  belongs_to :to_user, class_name: 'User', touch: true
  belongs_to :reply_to_message, class_name: 'Message'

  scope :undeleted_by_sender, lambda{where('deleted_by_sender is null or deleted_by_sender = false')}
  scope :undeleted_by_recipient, lambda{where('deleted_by_recipient is null or deleted_by_recipient = false')}
  scope :unread, lambda{where('is_read is null or is_read = false')}
  scope :newest, -> {joins('INNER JOIN (SELECT from_user_id, MAX(created_at) AS maxDate FROM `messages` GROUP BY from_user_id, to_user_id) AS Tmp ON messages.from_user_id = Tmp.from_user_id AND messages.created_at = Tmp.maxDate')}

  after_create :send_email_notification, :add_points

  def to_user_username=(name)
    self.to_user = User.find_by_username(name)
  end

  def to_user_username
    to_user.try(:username)
  end

  def read!
    update_attribute(:is_read, true)
  end

  def delete_by_sender!
    update_attribute(:deleted_by_sender, true)
  end

  def delete_by_recipient!
    update_attribute(:deleted_by_recipient, true)
  end

  def send_email_notification
    if ::SENDING_EMAILS
      NotificationsMailer.new_message(self).deliver if to_user.gets_email_for_private_message && !to_user.email_digest_for_private_message?
    end    
  end

  def add_points
    self.from_user.points.create score: ActionPoints.private_message_sent, action: 'private_message_sent', actionable_type: 'Message', actionable_id: self.id
  end

  def target_url
    Rails.application.routes.url_helpers.message_url(self)
  end
end