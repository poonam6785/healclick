class AddIsPublicToUserCondition < ActiveRecord::Migration
  def change
    add_column :user_conditions, :is_public, :boolean
  end
end
