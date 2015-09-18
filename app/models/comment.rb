class Comment < ActiveRecord::Base
  include Utf8Sanitized
  include Rails.application.routes.url_helpers

  has_many :comments, foreign_key: :parent_id, dependent: :destroy
  has_many :helpfuls, as: :markable, dependent: :destroy
  has_many :luvs, as: :luvable, dependent: :destroy

  has_many :activity_logs, as: :activity, dependent: :destroy

  belongs_to :commentable, polymorphic: true, counter_cache: true, touch: true
  belongs_to :parent, class_name: "Comment", counter_cache: true, touch: true
  belongs_to :user

  before_save :set_commentable
  after_save :remove_activity, if: :anonymous_changed?

  after_create :send_notification, :check_someone_was_mentioned, :update_post_metrics, :create_activity_post, :set_last_interaction
  after_destroy :update_post_metrics

  default_scope lambda { where("comments.deleted = false or comments.deleted is null") }
  has_attached_file :attachment, styles: { tiny: "30x30#", thumb: "100x100#", small: "180x180#", small_resized: "230x160>", medium: "250x250#", medium_resized: "350x250>", large: "700x500>" }
  validates_attachment_content_type :attachment, :content_type => %w(image/jpeg image/jpg image/png image/gif)

  scope :without_parent, lambda { where("parent_id is null") }
  scope :with_parent, lambda { where("parent_id is not null") }

  scope :latest, lambda { order("comments.created_at desc") }

  def send_notification
    Notification.comment_created(self)
    Notification.comment_after(self)
    #Notification.action_created(self)
  end

  def luv!(from_user)
    luvs.where(:user_id => from_user.id).first_or_create
    Notification.luved_comment(from_user, self)
  end

  def set_commentable
    if commentable.blank? && parent.present?
      self.commentable = parent.commentable
    end
  end

  def mentioned_users
    return @mentioned_users if @mentioned_users.present?
    pattern = /@([a-zA-Z0-9]*)/
    usernames = content.scan(pattern).flatten
    @mentioned_users = usernames.map { |username| User.find_by_username(username) }
  end

  def someone_mentioned?
    mentioned_users.present?
  end

  def check_someone_was_mentioned
    if someone_mentioned?
      mentioned_users.each do |mentioned_user|
        Notification.user_got_mentioned(mentioned_user, self)
      end
    end
  end

  def update_post_metrics
    commentable.update_interactions_count! if commentable.respond_to?(:update_interactions_count!)
  end

  def delete!
    update_attribute(:deleted, true)
  end

  def comments_content
    comments.map(&:content)
  end

  def set_last_interaction
    return if parent.blank?
    parent.update_attribute(:last_interaction_at, Time.now)
  end

  def media_comment?
    content =~ Regexp.union(Post::REGEX.values)
  end

  private

  def remove_activity
    self.activity_logs.destroy_all if anonymous?
  end

  def create_activity_post
    unless self.anonymous?
      becomes = commentable.class
      becomes = Photo if becomes == CroppedPhoto
      becomes = Post if becomes == Review
      commentable_title = if becomes == Photo
        "#{commentable.user.try(:username)}'s Photo"
      else
        commentable.to_s
      end
      h = ActionController::Base.helpers
      if becomes == Photo
        link = user_photo_path(self.commentable.user, self.commentable, expanded: true, comment_id: self.parent.try(:id), anchor: "comment_#{self.id}")
      else
        link = polymorphic_path(self.commentable.becomes(becomes), expanded: true, comment_id: self.parent.try(:id), anchor: "comment_#{self.id}" )
      end
      activity_content = "added a reply to #{ActionController::Base.helpers.link_to commentable_title, link}"
      activity_content << "<br /><p>\"#{h.truncate(self.content, length: 400)}\"</p>" if self.content.strip.present?
      activity_content << "<p>#{h.image_tag(self.attachment.url(:large))}</p>" if self.attachment.present?
      user.posts.create content: activity_content, hide_for_feed: true, activity_reply: true, activity_post_id: commentable.id, comment_id: self.id
    end
  end

end