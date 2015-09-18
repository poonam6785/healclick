require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdmin
  module Config
    module Actions

      class Recover < Base        
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :bulkable? do
          true
        end

        register_instance_option :controller do
          Proc.new do
            @entries = list_entries
            @abstract_model.model.restore(@entries.pluck(:id))
            redirect_to back_or_index
          end
        end
      end
    end
  end
end