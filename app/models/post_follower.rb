class PostFollower < ActiveRecord::Base

  belongs_to :post, touch: true
  belongs_to :user

end