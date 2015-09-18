class AddSuggestedToConditions < ActiveRecord::Migration
  def change
    add_column :conditions, :suggested, :boolean
  end
end
