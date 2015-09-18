class AddSlugToConditions < ActiveRecord::Migration
  def change
    add_column :conditions, :slug, :string
    add_index :conditions, :slug
    Condition.reset_column_information
    Condition.find_each(&:save)
  end
end
