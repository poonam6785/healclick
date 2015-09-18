require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdmin
  module Config
    module Actions
      class ExportSummaries < Base
        RailsAdmin::Config::Actions.register(self)
        
        register_instance_option :link_icon do
         'icon-upload'
        end
        register_instance_option :root? do
          true
        end
        register_instance_option :controller do
          Proc.new do
            if params[:commit].present?
              send_data TreatmentSummary.to_csv_with_conditions, type: 'text/csv; charset=utf-8; header=present', disposition: 'attachment; filename=summaries.csv'
            end
          end
        end
      end
    end
  end
end