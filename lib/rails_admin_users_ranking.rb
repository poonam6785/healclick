require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdmin
  module Config
    module Actions
      class UsersRanking < Base
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :link_icon do
         'icon-star-empty'
        end
        register_instance_option :root? do
          true
        end

        register_instance_option :controller do
          Proc.new do
            @users = User.joins(:versions).where('(versions.item_type = "Treatment" || versions.item_type = "Symptom") && versions.created_at > ?', 2.months.ago).group('users.id').select('count(*) as total_rank, users.username').order('total_rank desc')
          end
        end
      end
    end
  end
end