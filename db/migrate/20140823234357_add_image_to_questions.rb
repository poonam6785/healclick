class AddImageToQuestions < ActiveRecord::Migration
  def up
    add_attachment :questions, :image
  end
end
