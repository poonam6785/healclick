class Post < ActiveRecord::Base
  include Utf8Sanitized
  include FlagShihTzu
  has_flags 1 => :activity_reply

  acts_as_paranoid

  REGEX = {
    image_link: /(?<!src=")https?:\/\/.+?\.(jpg|jpeg|bmp|gif|png)(\?\S+)?/i,
    youtube_video: /https?:\/\/(www.)?(youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/watch\?feature=player_embedded&v=)([A-Za-z0-9_-]*)(\&\S+)?(\?\S+)?/,
    vimeo_video: /https?:\/\/(www.)?vimeo\.com\/([A-Za-z0-9._%-]*)((\?|#)\S+)?/    
  }

  belongs_to :user, counter_cache: true
  belongs_to :post_category, counter_cache: true
  belongs_to :treatment_review, touch: true
  belongs_to :doctor_review, touch: true
  belongs_to :comment
  has_one :photo, dependent: :destroy
  has_many :helpfuls, as: :markable, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :luvs, as: :luvable, dependent: :destroy
  has_many :post_followers, dependent: :destroy
  has_many :users, through: :post_followers
  has_and_belongs_to_many :conditions

  belongs_to :last_interaction_user, class_name: 'User'

  has_many :activity_logs, as: :activity

  before_create :initialize_latest_activity
  before_create :give_all_conditions
  after_create :check_someone_was_mentioned, :create_activity_log, :add_points

  default_scope lambda{where("posts.deleted = false OR posts.deleted is null")}

  scope :topics, lambda{where(type: "Post")}
  scope :reviews, lambda{where(type: "Review")}
  scope :not_anonymous, ->{where(anonymous: [false, nil])}
  scope :with_ids, lambda{|ids|
    where(id: ids)
  }

  scope :followed_by, lambda{|user|
    joins(user: :following_users).
    where("user_followers.following_user_id = :user_id OR posts.user_id = :user_id", user_id: user.id).
    group("posts.id")
  }

  scope :recently_created, lambda{
    order("created_at desc")
  }

  scope :with_user_condition, lambda{
    joins("left join conditions ON (users.main_condition_id = conditions.id)")
  }

  scope :with_user_matching, lambda{|user|
    joins("left join users as usersb on (posts.user_id = usersb.id)").
    joins("left join patient_matches on (usersb.id = patient_matches.to_user_id)").
    where("patient_matches.from_user_id = ?", user.id)
  }

  scope :by_treatments, lambda{|treatment_summaries|
    joins(treatment_review: :treatment).
    where("treatments.treatment_summary_id IN (#{treatment_summaries.map(&:id).join(", ")})")
  }

  scope :by_conditions, lambda{|condition_ids, user|
    if condition_ids == 'my_conditions'
      if user.present?
        conditions = [user.main_condition.id] + user.user_conditions.map(&:condition_id)
      else
        conditions = [0]
      end
    else
      conditions = Array.wrap(condition_ids).map(&:to_i)
    end
    joins(:conditions).
    where("conditions.id IN (#{conditions.try(:join, ',')}) OR all_conditions = 1")
  }

  scope :by_treatment_condition, lambda{|condition_id, user|
    return if condition_id == 'any'
    s = joins(treatment_review: :conditions)
    if condition_id == 'my_conditions' && user.present?
      s.where(conditions: {id: ([user.main_condition.try(:id)] + user.user_conditions.map(&:condition_id)).compact })
    else
      s.where(conditions: {slug: condition_id.try(:gsub, /\A\d+-/, '')})
    end
  }
  scope :by_doctor_condition, lambda{|condition_id, user|
    s = joins(doctor_review: :conditions)
    if condition_id == 'my_conditions' && user.present?
      s.where(conditions: {id: ([user.main_condition.try(:id)] + user.user_conditions.map(&:condition_id)).compact })
    else
      s.where(conditions: {id: condition_id})
    end
  }

  scope :by_type, lambda{|type|
    where(type: type)
  }

  scope :by_category, lambda{|category_id|
    where(post_category_id: category_id)
  }

  scope :blogs, lambda{
    where(post_category_id: PostCategory.find_by_name('Blog').try(:id))
  }

  scope :faqs, lambda{
    where(post_category_id: PostCategory.find_by_name('FAQ').try(:id))
  }

  scope :doctor_reviews, -> {
    where('posts.doctor_review_id is not null')
  }

  scope :treatment_reviews, -> {
    where('posts.treatment_review_id is not null')
  }

  scope :for_feed, ->{where(hide_for_feed: false)}

  scope :not_my, ->(user_id) {where('user_id != ?', user_id)}

  scope :not_tracking_updates, ->{where(tracking_update: false)}
  scope :tracking_updates, ->{where(tracking_update: true)}

  searchable do
    text :title, :content
    text :username do
      user.try(:username)
    end
    text :user_full_name do
      user.try(:full_name_with_username)
    end
    text :user_full_name_with_username do
      user.try(:full_name_with_username)
    end
    text :category_name do
      post_category.try(:name)
    end
    text :comments do
      comments.map { |comment| comment.content }
    end
    text :comments_username do
      comments.map {|comment| comment.try(:user).try(:username)}
    end
    text :subcomments_content do
      comments.with_parent.each do |c|
        c.comments.map { |comment| comment.content }
      end
    end
    text :treatment_review_content do
      treatment_review.try(:content)
    end
  end

  def to_s
    title.present? ? title : 'Hi'
  end

  def to_param
    "#{title} #{id}".parameterize
  end

  def self.from_param(param)
    find_by_id! param.split('-').last
  end
  
  def self.text_search(options = {})
    solr_search do
      fulltext options[:query] do
        boost_fields title: 5.0
        boost_fields content: 2.5
      end
      paginate per_page: 150
    end
  end

  def view!
    update_attribute(:views_count, views_count.to_i + 1)
  end

  def luv!(from_user)
    luv = luvs.where(:user_id => from_user.id).first_or_create
    Notification.loved_post(from_user, self)
    # Add points to post's author
    if !ActionPoints.luv_for_post.blank? && !self.user.points.exists?(actionable_type: 'Post', actionable_id: self.id, action: 'luv_for_post')
      self.user.points.create score: ActionPoints.luv_for_post, action: 'luv_for_post', actionable_type: 'Post', actionable_id: self.id
    end

    # And sender
    if !ActionPoints.luvs_sent.blank? && !from_user.points.exists?(actionable_type: 'Post', actionable_id: self.id, action: 'luvs_sent')
      from_user.points.create score: ActionPoints.luvs_sent, action: 'luvs_sent', actionable_type: 'Post', actionable_id: self.id
    end
  end

  def picture=(p)
    self.photo = Photo.new(attachment: p)
  end

  def mentioned_users
    return @mentioned_users if @mentioned_users.present?
    return if content.blank?
    
    pattern   = /@([a-zA-Z0-9_\.]*)/
    usernames = content.scan(pattern).flatten
    @mentioned_users = usernames.map{|username| User.find_by_username(username)}
    @mentioned_users
  end

  def someone_mentioned?
    mentioned_users.present?
  end

  def check_someone_was_mentioned
    if !activity_reply? && someone_mentioned?
      mentioned_users.each do |mentioned_user|
        Notification.user_got_mentioned(mentioned_user, self)
      end
    end
  end

  def update_interactions_count!(skip_timestamp = false)
    self.interactions_count = comments.count.to_i
    last_comment = comments.latest.first
    self.last_interaction_user_id = if last_comment.try(:anonymous?)
      0
    else
      last_comment.try(:user_id) || self.user_id
    end
    unless skip_timestamp
      self.last_interaction_at = comments.latest.first.try(:created_at) || self.created_at
    end
    save(validate: false)
  end

  def initialize_latest_activity
    self.last_interaction_at = Time.now
    self.last_interaction_user_id = self.user_id
    self.interactions_count = 0
  end

  def delete!
    update_attribute(:deleted, true)
  end

  def create_activity_log
    return if user.blank?
    if self.is_a?(Review)
      user.activity_logs.create!(activity: self, title: "Review Created: ", created_at: self.created_at, updated_at: self.updated_at, anonymous: anonymous)
    else
      user.activity_logs.create!(activity: self, title: "Post Created: ", created_at: self.created_at, updated_at: self.updated_at, anonymous: anonymous)
    end
  end
  handle_asynchronously :create_activity_log, queue: :ongoing_jobs

  def add_points
    self.user.points.create action: 'topic_post', score: ActionPoints.topic_post, actionable_type: 'Post', actionable_id: self.id if self.type == 'Post'
  end

  def media_post?
    content =~ Regexp.union(REGEX.values)
  end

  def text_post?
    !media_post?
  end

  def faq_or_blog?
    PostCategory.where(name: %w(FAQ Blog)).map(&:id).include?(post_category_id)
  end

  private

  def give_all_conditions
    self.all_conditions = true if PostCategory.where(name: %w(FAQ Blog)).map(&:id).include?(post_category_id)
  end
end