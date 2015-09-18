class FixTreatments < ActiveRecord::Migration
  def self.up
    add_column :treatments, :numeric_level, :integer
  end

  def self.down
    remove_column :treatments, :numeric_level, :integer
  end  
end
