class QuestionnaireController < ApplicationController
  before_action :authenticate_user!

  def save_categories
    current_user.question_categories.destroy_all
    current_user.question_categories << QuestionCategory.where(id: params[:question_category])
    find_question
  end

  def next_question
    if params[:question_answer_ids].present?
      params[:question_answer_ids].each do |a|
        next if a.blank?
        current_user.answers.create answer_params.merge(question_answer_id: a)
      end
    else
      current_user.answers.create answer_params
    end
    find_question
  end

  private

  def answer_params
    params.require(:answer).permit(:question_answer_id, :question_id)
  end

  def find_question
    @question = Question.by_question_category_id(current_user.question_categories.map(&:id)).unanswered_by(current_user).first
  end
end
