class AddStartedOnToUserCondition < ActiveRecord::Migration
  def change
    add_column :user_conditions, :started_on, :date
  end
end
