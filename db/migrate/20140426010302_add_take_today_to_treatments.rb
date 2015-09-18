class AddTakeTodayToTreatments < ActiveRecord::Migration
  def change
    add_column :treatments, :take_today, :boolean
  end
end
