require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdmin
  module Config
    module Actions
      class VersionStats < Base
        RailsAdmin::Config::Actions.register(self)
        
        register_instance_option :link_icon do
         'icon-time'
        end

        register_instance_option :root? do
          true
        end

        register_instance_option :controller do
          Proc.new do
            if params[:commit].present? && !params[:models].blank?
              start_date = Date.parse(%w(1 2 3).map { |e| params["start_date(#{e}i)"] }.join('-'))
              end_date = Date.parse(%w(1 2 3).map { |e| params["end_date(#{e}i)"] }.join('-'))
              versions = PaperTrail::Version
                .where(item_type: params[:models])
                .where('created_at between ? and ?', start_date, end_date)
                .where('event = "create" OR event = "update"')
                .group('date(created_at)')
                .select('date(created_at) as date, count(*) as total_count, count(distinct whodunnit) as users_count, item_type')
              if versions.present?
                csv = CSV.generate do |csv|
                  csv << (versions.first.attributes.keys - ['id']).map(&:titleize)
                  versions.each do |version|
                    csv << version.attributes.reject {|k,v| k == 'id'}.values
                  end
                end
                send_data csv, type: 'text/csv; charset=utf-8; header=present', disposition: 'attachment; filename=version_stats.csv'
              end
            end
          end
        end
      end
    end
  end
end