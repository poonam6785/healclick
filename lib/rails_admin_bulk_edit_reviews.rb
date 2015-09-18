require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdmin
  module Config
    module Actions

      class BulkEditReviews < Base        
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :bulkable? do
          true
        end

        register_instance_option :controller do
          Proc.new do
            @reviews = list_entries
            @pass_params = params.slice(:bulk_action, :bulk_ids, :model_name)
            if (new_treatment_name = params[:new_treatment_name]).present?
              @reviews.update_all(:title => "#{new_treatment_name} Review")
              @treatments = Treatment.where(id: @reviews.map {|review| review.treatment_review.try(:treatment).try(:id)})
              @summary = TreatmentSummary.where(treatment_name: new_treatment_name).first_or_create
              @treatments.update_all(treatment: new_treatment_name, treatment_summary_id: @summary.id)
              @summary.reload_numbers              
              redirect_to rails_admin.index_path('Review'), notice: "Treatment name updated successfully for ids: #{@reviews.map(&:id).join(',')}"
            end
          end
        end
      end
    end
  end
end