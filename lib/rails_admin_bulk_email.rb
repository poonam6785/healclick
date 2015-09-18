require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdmin
  module Config
    module Actions

      class BulkEmail < Base        
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :bulkable? do
          true
        end

        register_instance_option :controller do
          Proc.new do
            @objects = list_entries
            raise @objects.inspect
          end
        end
      end
    end
  end
end