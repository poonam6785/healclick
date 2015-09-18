class ActivityLogger
  def initialize(activity)
    @attributes = activity.activity_attributes
  end

  def user
    @user ||= User.find_by_id(@attributes[:user_id])
  end

  def log_activity?
    case @attributes[:class_name]
      when 'Photo', 'CroppedPhoto'
        @attributes[:post_id].blank?
      else true
    end
  end

  def notice_followed_users
    return if user.blank?
    return unless log_activity?
    previous_activity = ActivityLog.where(favorite_user_id: @attributes[:user_id], activity_type: @attributes[:class_name])
    previous_activity = previous_activity.where(created_at: 1.hour.ago..Time.now) unless %w(Photo CroppedPhoto).include?(@attributes[:class_name])
    title = activity_log_title
    ActivityLog.transaction do
      if previous_activity.any?
        previous_activity.update_all created_at: Time.now, updated_at: Time.now
        # For new following users
        if previous_activity.size != user.followed_users.size
          user_ids = previous_activity.map(&:user_id)
          user.following_users.pluck(:following_user_id).compact.each do |fuser_id|
            ActivityLog.create! user_id: fuser_id, activity_id: @attributes[:id], activity_type: @attributes[:class_name], title: title, favorite_user_id: @attributes[:user_id] unless user_ids.include?(fuser_id)
          end
        end
      else
        user.following_users.pluck(:following_user_id).compact.each do |fuser_id|
          ActivityLog.create! user_id: fuser_id, activity_id: @attributes[:id], activity_type: @attributes[:class_name], title: title, favorite_user_id: @attributes[:user_id]
        end
      end
    end
  end

  handle_asynchronously :notice_followed_users, queue: :ongoing_jobs

  def activity_log_title
    ''
  end
end