class Redirect < ActiveRecord::Base
  validates :from, presence: true
  validates :to, presence: true
end