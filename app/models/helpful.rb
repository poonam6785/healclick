class Helpful < ActiveRecord::Base

  belongs_to :markable, polymorphic: true, counter_cache: true, touch: true
  belongs_to :user

  scope :for_post,    lambda{|post| where(markable_id: post.id, markable_type: 'Post')}
  scope :for_comment, lambda{|comment| where(markable_id: comment.id, markable_type: 'Comment')}

  after_create :send_notification, :add_points

  def send_notification
    Notification.marked_as_helpful(user, markable)
  end

  private

  def add_points
    markable = self.markable
    unless markable.user.points.exists?(actionable_type: markable.class.name, actionable_id: markable.id)
      markable.user.points.create score: ActionPoints.helpful_vote_received, action: 'helpful_vote_received', actionable_type: markable.class.name, actionable_id: markable.id
    end
  end

end