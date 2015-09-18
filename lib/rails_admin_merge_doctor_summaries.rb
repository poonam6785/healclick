require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdmin
  module Config
    module Actions

      class MergeDoctorSummaries < Base        
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :bulkable? do
          true
        end

        register_instance_option :controller do
          Proc.new do
            @objects = list_entries.order('doctor_summaries.created_at DESC')
            if @objects.count > 1
              @objects.update_all(doctor_name: @objects.first.doctor_name)
              @objects.first.save
            end
            redirect_to back_or_index, notice: "Doctor Summaries successfully merged. Resulting summary id: #{@objects.first.id}"
          end
        end
      end
    end
  end
end