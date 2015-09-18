require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdmin
  module Config
    module Actions
      class ExportDuplicateSymptoms < Base
        RailsAdmin::Config::Actions.register(self)
        
        register_instance_option :link_icon do
         'icon-upload'
        end
        register_instance_option :collection? do
          true
        end
        register_instance_option :controller do
          Proc.new do
            if params[:commit].present?
              counts = Symptom.group(:user_id).group("lower(trim(symptom))").count.reject {|k,v| v.to_i <= 1}
              symptoms = counts.keys.map {|k| Symptom.where(user_id: k.first).where("lower(trim(symptom)) = ?", k.last)}.flatten
              csv = CSV.generate do |csv|
                csv << ['id', 'symptom', 'user id', 'username', 'created at', 'rating']
                symptoms.each do |s|
                  csv << [s.id, s.symptom, s.user_id, s.user.try(:username), s.created_at, s.numeric_level]
                end
              end
              send_data csv, type: 'text/csv; charset=utf-8; header=present', disposition: 'attachment; filename=summaries.csv'
            end
          end
        end
      end
    end
  end
end