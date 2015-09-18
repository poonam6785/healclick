require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdmin
  module Config
    module Actions
      class Questionnaire < Base
        RailsAdmin::Config::Actions.register(self)
        
        register_instance_option :link_icon do
         'icon-bars'
        end
        register_instance_option :root? do
          true
        end

        register_instance_option :controller do
          Proc.new do
          end
        end
      end
    end
  end
end