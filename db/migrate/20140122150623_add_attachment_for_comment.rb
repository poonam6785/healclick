class AddAttachmentForComment < ActiveRecord::Migration
  def change
    add_attachment :comments, :attachment
  end
end
