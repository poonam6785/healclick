class FixPhotoPath < ActiveRecord::Migration
  def up
    h = ActionController::Base.helpers
    r = Rails.application.routes.url_helpers
    ActivityLog.where('title LIKE ?', '%href="/photos/%').find_each do |log|
      if log.activity.present? && log.activity.commentable.present?
        log.title = log.title.gsub /"\/photos\/(.*)">/, "\"#{r.user_photo_path(log.activity.commentable.user, log.activity.commentable, expanded: true, comment_id: log.activity.parent.try(:id), anchor: "comment_#{log.activity.id}")}\">"
        log.save
      end
    end
  end

  def down

  end
end
