class CreateSymptomSummaries < ActiveRecord::Migration
  def change
    create_table :symptom_summaries do |t|
      t.string :symptom_name
      t.float :average_level

      t.timestamps
    end
  end
end
