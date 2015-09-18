class QuestionCategoriesUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :question_category
end