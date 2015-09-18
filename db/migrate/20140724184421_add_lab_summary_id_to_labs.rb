class AddLabSummaryIdToLabs < ActiveRecord::Migration
  def change
    add_column :labs, :lab_summary_id, :integer, null: false
    add_index :labs, :lab_summary_id
  end
end
