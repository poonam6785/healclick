class SubCategory < ActiveRecord::Base
  belongs_to :category
  has_many :symptom_summaries
  has_many :users, through: :symptom_summaries
end
