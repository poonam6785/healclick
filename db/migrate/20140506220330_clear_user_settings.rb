class ClearUserSettings < ActiveRecord::Migration
  def up
  	RailsSettings::Settings.unscoped.where('var="condition_id"').destroy_all
  end

  def down

  end
end
