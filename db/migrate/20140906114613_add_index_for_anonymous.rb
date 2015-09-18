class AddIndexForAnonymous < ActiveRecord::Migration
  def change
    add_index :activity_logs, :anonymous
  end
end
