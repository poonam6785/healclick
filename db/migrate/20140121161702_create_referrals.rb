class CreateReferrals < ActiveRecord::Migration
  def change
    create_table :referrals do |t|
      t.string :link
      t.string :token
      t.integer :user_id

      t.timestamps
    end
  end
end
