class Question < ActiveRecord::Base
  has_attached_file :image, styles: { medium: '300x300>' }
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/

  belongs_to :question_category
  has_many :answers
  has_many :question_answers

  scope :by_question_category_id, ->(ids) {(where(question_category_id: ids))}
  scope :unanswered_by, lambda{|user|
    ids =  user.answers.map(&:question_id).blank? ? '' :  user.answers.map(&:question_id)
    where('id NOT IN (?)', ids)
  }

  default_scope order('created_at ASC')
end