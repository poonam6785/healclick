class CreateNoindexRules < ActiveRecord::Migration
  def change
    create_table :noindex_rules do |t|
      t.string :url

      t.timestamps
    end
  end
end
