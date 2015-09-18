class Photo < ActiveRecord::Base

  belongs_to :user
  belongs_to :post
  has_many :comments, as: :commentable, dependent: :destroy

  before_save :set_title
  after_save :add_points

  log_activity_on :after_create

  has_attached_file :attachment,  styles: {medium: "250x250#", medium_resized: "350x250>", large: "700x500>" }, convert_options: { all: '-strip' },
                                  path: "/system/photos/:attachment/:id_partition/:style/:filename"

  validates_attachment_content_type :attachment, :content_type => ['image/jpeg', 'image/jpg', 'image/png', 'image/gif']
  
  def to_s
    'My Photo'  
  end

  private

  def add_points
    if !self.post_id.nil? && self.attachment_file_name_changed? && attachment_file_name_was.blank?
      self.post.user.points.create action: 'post_photo_uploaded', score: ActionPoints.post_photo_uploaded, actionable_type: 'Post', actionable_id: self.id
    end
  end

  def set_title
    self.title = self.attachment_file_name if self.title.blank? && self.attachment_file_name.present?
  end

end
