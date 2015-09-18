require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdmin
  module Config
    module Actions

      class BulkEditTreatmentSummaries < Base        
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :bulkable? do
          true
        end

        register_instance_option :controller do
          Proc.new do
            @objects = list_entries.order('treatment_summaries.created_at DESC')
            @pass_params = params.slice(:bulk_action, :bulk_ids, :model_name, :return_to)
            if params["treatment_summaries"]
              # Create redirect links for the destroyed treatment summaries
              parent = @objects.find_by_id(params["treatment_summaries"])
              @objects.select{|x| x.id != parent.id}.each do |t|
                parent.treatment_summary_redirects.create(old_link: t.to_param)
              end
              @objects.update_all(treatment_name: parent.treatment_name)
              parent.merge_summaries_with_same_treatment_name

              flash[:notice] = "Treatment Summaries successfully merged. Resulting summary id: #{parent.id}"
                            
              if params[:return_to].present?
                redirect_to params[:return_to]
              else
                redirect_to rails_admin.index_path('TreatmentSummary')
              end
            end            
          end
        end
      end
    end
  end
end