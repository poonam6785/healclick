class AddQuestionnaireSetting < ActiveRecord::Migration
  def change
    SystemSetting.get(:enabled_questionnaire).update_attributes(value: false)
  end
end
