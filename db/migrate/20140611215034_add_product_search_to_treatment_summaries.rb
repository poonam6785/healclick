class AddProductSearchToTreatmentSummaries < ActiveRecord::Migration
  def change
    add_column :treatment_summaries, :product_search, :boolean, default: false
  end
end
