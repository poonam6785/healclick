class Luv < ActiveRecord::Base
  belongs_to :user
  belongs_to :luvable, polymorphic: true, counter_cache: true, touch: true

  validates :user_id, presence: true
  validates :luvable_id, presence: true
  validates_uniqueness_of :luvable_id, scope: [:luvable_type, :user_id]
end
