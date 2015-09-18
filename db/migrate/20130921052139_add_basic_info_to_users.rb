class AddBasicInfoToUsers < ActiveRecord::Migration
  def change
    add_column :users, :birth_date, :date
    add_column :users, :gender, :string
    add_column :users, :location, :string
    add_column :users, :bio, :text
    add_column :users, :profile_photo_id, :integer
    add_column :users, :basic_info_step, :boolean
    add_column :users, :main_condition_step, :boolean
    add_column :users, :medical_info_step, :boolean
    add_column :users, :finished_profile, :boolean
  end
end
