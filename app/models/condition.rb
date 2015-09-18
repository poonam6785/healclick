class Condition < ActiveRecord::Base

  has_many :user_conditions
  has_many :users, through: :user_conditions
  has_and_belongs_to_many :treatment_summaries
  has_and_belongs_to_many :treatment_reviews

  scope :active, lambda {where(active: true)}
  scope :not_user_conditions, ->(user) {active.where('id not in (?)', [user.main_condition_id] + user.conditions.map(&:id))}
  scope :search, lambda{ |query| active.select('DISTINCT(name)').where("lower(name) LIKE ?", "%#{query.to_s.downcase}%")}
  scope :by_slug, ->(slug) {active.where(slug: slug)}

  validates :name, presence: true

  before_save :generate_slug

  default_scope {order('name asc')}

  def activate!
    update_attributes(active: true)
  end

  def to_param
    "#{id} #{name}".parameterize
  end

  def generate_slug
    assign_attributes slug: name.to_s.parameterize
  end
end