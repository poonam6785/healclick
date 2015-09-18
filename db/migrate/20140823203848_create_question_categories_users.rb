class CreateQuestionCategoriesUsers < ActiveRecord::Migration
  def change
    create_table :question_categories_users do |t|
      t.belongs_to :question_category
      t.belongs_to :user
    end
    add_index :question_categories_users, :question_category_id
    add_index :question_categories_users, :user_id
  end
end
