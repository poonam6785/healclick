class CroppedPhoto < Photo

  has_attached_file :attachment,  styles: {medium: '250x250#', large: '700x500>' }, processors: [:cropper], convert_options: { all: '-strip' }, path: '/system/photos/:attachment/:id_partition/:style/:filename', auto_orient: false

  validates_attachment_content_type :attachment, content_type: %w(image/jpeg image/jpg image/png image/gif)

  after_create :touch_posts

  def to_s
    'My Photo'
  end

  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end

  def pic_geometry(style = :original)
    @geometry ||= {}
    @geometry[style] ||= Paperclip::Geometry.from_file(attachment.url(style))
  end

  def crop!(options = {})
    update_attributes(options.slice(:crop_x, :crop_y, :crop_w, :crop_h))
    attachment.reprocess!
  end

  private

  def reprocess_attachment
    attachment.reprocess!
  end

  def touch_posts
    user.posts.find_each(&:touch)
  end

end
