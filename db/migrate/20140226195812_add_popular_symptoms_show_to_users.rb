class AddPopularSymptomsShowToUsers < ActiveRecord::Migration
  def change
    add_column :users, :popular_symptoms_show, :boolean, default: true
  end
end
