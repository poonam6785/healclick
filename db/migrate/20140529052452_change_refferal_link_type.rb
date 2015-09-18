class ChangeRefferalLinkType < ActiveRecord::Migration
  def change
    change_column :referrals, :link, :text
  end
end
