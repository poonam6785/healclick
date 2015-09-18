class RemoveAkState < ActiveRecord::Migration
  def up
  	User.where('state = "AK"').update_all state: nil
  end

  def down
  	
  end
end
