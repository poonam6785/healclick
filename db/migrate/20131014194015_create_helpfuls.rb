class CreateHelpfuls < ActiveRecord::Migration
  def change
    create_table :helpfuls do |t|
      t.integer :user_id
      t.integer :markable_id
      t.string :markable_type

      t.timestamps
    end
  end
end