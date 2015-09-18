class AddMultipleAnswersToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :multiple_answers, :boolean, default: false
  end
end
