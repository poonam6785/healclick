class AddNewPostCategory < ActiveRecord::Migration
  def up
  	PostCategory.create name: 'Introductions'
  end

  def down
  	
  end
end
