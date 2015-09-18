class AddLockedToComments < ActiveRecord::Migration
  def change
    add_column :comments, :locked, :boolean
  end
end
