class AddAttachmentProcessingToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :attachment_processing, :boolean
  end
end
