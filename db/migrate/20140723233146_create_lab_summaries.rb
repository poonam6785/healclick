class CreateLabSummaries < ActiveRecord::Migration
  def change
    create_table :lab_summaries do |t|
      t.string :lab
      t.integer :labs_count

      t.timestamps
    end
  end
end
