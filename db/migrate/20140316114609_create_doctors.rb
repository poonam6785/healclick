class CreateDoctors < ActiveRecord::Migration
  def change
    create_table :doctors do |t|
      t.string :name
      t.boolean :recommended
      t.string :location
      t.string :period

      t.timestamps
    end
  end
end
