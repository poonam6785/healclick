class AddMyHealthStepToUsers < ActiveRecord::Migration
  def change
    add_column :users, :my_health_step, :boolean
  end
end
