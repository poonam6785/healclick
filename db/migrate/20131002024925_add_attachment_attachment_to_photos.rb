class AddAttachmentAttachmentToPhotos < ActiveRecord::Migration
  def self.up
    change_table :photos do |t|
      t.attachment :attachment
    end
  end

  def self.down
    drop_attached_file :photos, :attachment
  end
end
