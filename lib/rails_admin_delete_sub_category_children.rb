require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdmin
  module Config
    module Actions

      class DeleteSubCategoryChildren < Base        
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :member? do
          true
        end

        register_instance_option :link_icon do
          'icon-trash'
        end

        register_instance_option :controller do
          Proc.new do
            if params[:commit].present?
              @object.symptom_summaries.destroy_all
              @object.destroy
              redirect_to back_or_index
            end
          end
        end
      end
    end
  end
end