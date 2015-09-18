class ActivityLog < ActiveRecord::Base

  belongs_to :user
  belongs_to :activity, polymorphic: true
  belongs_to :favorite_user, foreign_key: 'favorite_user_id', class_name: 'User'

  scope :not_anonymous, lambda{where('anonymous = ? OR anonymous is null', false)}
  scope :from_favorite_users, -> {where('favorite_user_id is not null')}
  scope :not_from_favorite_users, -> {where('favorite_user_id is null')}
  scope :by_type, ->(type){where('activity_type = ?', type)}
  scope :for_user, ->(user_id){where('favorite_user_id = ?', user_id)}
  scope :recent, -> {order('updated_at DESC')}
end