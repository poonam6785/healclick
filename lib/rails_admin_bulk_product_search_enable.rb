require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdmin
  module Config
    module Actions

      class BulkProductSearchEnable < Base
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :bulkable? do
          true
        end

        register_instance_option :controller do
          Proc.new do
            list_entries.update_all product_search: true
            redirect_to rails_admin.index_path('TreatmentSummary'), notice: 'Successfully updated'
          end
        end
      end
    end
  end
end