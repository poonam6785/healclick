class ChangeDefaultreminderForSymptoms < ActiveRecord::Migration
  def change
    Symptom.all.update_all notify: true
    change_column_default :symptoms, :notify, true
  end
end
