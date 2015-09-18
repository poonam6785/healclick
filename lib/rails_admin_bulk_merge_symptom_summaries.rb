require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdmin
  module Config
    module Actions

      class BulkMergeSymptomSummaries < Base        
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :bulkable? do
          true
        end

        register_instance_option :controller do
          Proc.new do
            @objects = list_entries.order('symptom_summaries.created_at DESC')
            @pass_params = params.slice(:bulk_action, :bulk_ids, :model_name)

            if params["symptom_summaries"]
              parent = @objects.find_by_id(params["symptom_summaries"])
              if @objects.count > 1              
                @objects.update_all(symptom_name: parent.symptom_name)
                parent.merge_summaries_with_same_symptom_name
              end
              flash[:notice] = "Symptom Summaries successfully merged. Resulting summary id: #{parent.id}"
                            
              if params[:return_to].present?
                redirect_to params[:return_to]
              else
                redirect_to rails_admin.index_path('SymptomSummary')
              end
            end
          end
        end
      end
    end
  end
end