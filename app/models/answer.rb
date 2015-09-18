class Answer < ActiveRecord::Base

  belongs_to :user
  belongs_to :question
  belongs_to :question_answer

  after_create :check_survey_status

  # Fields for rails admin export
  def question_text
    question.try(:text)
  end

  def username
    user.try(:username)
  end

  def answer_text
    question_answer.try(:text)
  end

  private

  def check_survey_status
    user.finish_survey if user.answers.size == user.question_categories.joins(questions: :question_answers).group('question_id').length
  end
end