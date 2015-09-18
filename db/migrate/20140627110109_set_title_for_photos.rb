class SetTitleForPhotos < ActiveRecord::Migration
  def change
    Photo.connection.execute('update photos set title = attachment_file_name where title is null and attachment_file_name is not null;')
  end
end
