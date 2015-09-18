class Category < ActiveRecord::Base
  has_many :sub_categories
  has_many :users, through: :sub_categories
end
