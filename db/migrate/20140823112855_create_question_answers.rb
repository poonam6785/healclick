class CreateQuestionAnswers < ActiveRecord::Migration
  def change
    create_table :question_answers do |t|
      t.text :text
      t.integer :question_id

      t.timestamps
    end
    add_index :question_answers, :question_id
  end
end
