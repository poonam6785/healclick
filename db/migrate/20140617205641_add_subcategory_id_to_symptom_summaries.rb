class AddSubcategoryIdToSymptomSummaries < ActiveRecord::Migration
  def change
    add_column :symptom_summaries, :sub_category_id, :integer
  end
end
