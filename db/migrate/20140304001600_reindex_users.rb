class ReindexUsers < ActiveRecord::Migration
  def change
    User.reindex
  end
end
