class RemoveStrongTags < ActiveRecord::Migration
  def change
    Comment.find_each do |comment|
      unless comment.content.try(:[], 'strong>').nil?
        comment.update_attributes content: comment.content.try(:gsub, /<\/?strong>/, '')
      end
    end
  end
end
