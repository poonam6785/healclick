require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdmin
  module Config
    module Actions

      class BulkEditTreatments < Base
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :bulkable? do
          true
        end

        register_instance_option :controller do
          Proc.new do
            @treatments = list_entries
            @pass_params = params.slice(:bulk_action, :bulk_ids, :model_name)
            if (new_treatment_name = params[:new_treatment_name]).present?
              old_names = @treatments.map(&:treatment).join(', ')
              @treatments.each do |treatment|
                treatment.update_attributes treatment: params[:new_treatment_name]
              end
              redirect_to rails_admin.index_path('Treatment'), notice: "Treatment name updated successfully for #{old_names}"
            end
          end
        end
      end
    end
  end
end