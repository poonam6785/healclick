class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.text :text
      t.integer :question_category_id

      t.timestamps
    end
  end
end
