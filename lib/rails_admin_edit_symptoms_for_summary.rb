require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdmin
  module Config
    module Actions

      class EditSymptomsForSummary < Base        
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :member? do
          true
        end

        register_instance_option :link_icon do
          'icon-edit'
        end

        register_instance_option :controller do
          Proc.new do
            if params[:commit].present?
              desired_params = params[:update_notify] ? params.slice(:symptom, :notify) : params.slice(:symptom)
              @object.symptoms.update_all desired_params
              redirect_to back_or_index
            end
          end
        end
      end
    end
  end
end