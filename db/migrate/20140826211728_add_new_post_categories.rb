class AddNewPostCategories < ActiveRecord::Migration
  def change
    PostCategory.transaction do
      PostCategory.create name: 'FAQ'
      PostCategory.create name: 'Blog'
    end
  end
end
