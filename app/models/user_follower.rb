class UserFollower < ActiveRecord::Base

  belongs_to :followed_user, class_name: "User", touch: true
  belongs_to :following_user, class_name: "User"

  after_create :send_notification

  def send_notification
    Notification.user_being_followed(following_user, followed_user)
  end

end