require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdmin
  module Config
    module Actions
      class PointLeaders < Base
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :link_icon do
         'icon-star-empty'
        end
        register_instance_option :root? do
          true
        end

        register_instance_option :controller do
          Proc.new do
            @users = User.joins(:points).select('SUM(`action_point_users`.score) as total, users.*').group('users.id').order('total desc').limit(100)
          end
        end
      end
    end
  end
end