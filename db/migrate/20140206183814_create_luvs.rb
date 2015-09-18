class CreateLuvs < ActiveRecord::Migration
  def change
    create_table :luvs do |t|
      t.integer :luvable_id
      t.string :luvable_type
      t.references :user, index: true

      t.timestamps
    end
  end
end
