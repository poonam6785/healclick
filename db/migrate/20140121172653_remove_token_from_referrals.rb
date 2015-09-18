class RemoveTokenFromReferrals < ActiveRecord::Migration
  def change
    remove_column :referrals, :token
  end
end
