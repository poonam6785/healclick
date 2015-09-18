require 'rails_admin/main_controller'
module RailsAdmin
  class MainController
    alias_method :old_get_collection, :get_collection
    alias_method :old_get_object, :get_object

    UNSCOPED_MODELS = %w(Post)

    def get_collection(model_config, scope, pagination)
      if UNSCOPED_MODELS.include? model_config.abstract_model.model.name
        old_get_collection(model_config, model_config.abstract_model.model.unscoped, pagination)
      else
        old_get_collection(model_config, scope, pagination)
      end
    end

    def back_or_index      
      return params[:return_to].presence && params[:return_to].include?(request.host) && (params[:return_to] != request.fullpath) ? params[:return_to] : index_path
    end

    def redirect_to_on_success
      notice = t('admin.flash.successful', name: @model_config.label, action: t("admin.actions.#{@action.key}.done"))

      if params["action"] == "edit" && params["model_name"] == "treatment_summary"
        if params[:_add_another]
          @redirect_path = new_path(return_to: params[:return_to])
        end
        object = @abstract_model.model.unscoped.find(params[:id])
        summaries = TreatmentSummary.where('lower(trim(treatment_name)) = ?', object.treatment_name.strip.downcase)
        if summaries.present? and summaries.count > 1
          @redirect_to = get_bulk_edit_treatment_summaries_path(bulk_ids: summaries.ids, from_edit: true, from_edit_object_id: object.id, return_to: @redirect_path)                
        end
      elsif params["action"] == "edit" && params["model_name"] == "symptom_summary"
        if params[:_add_another]
          @redirect_path = new_path(return_to: params[:return_to])
        end
        object = @abstract_model.model.unscoped.find(params[:id])
        summaries = SymptomSummary.where('lower(trim(symptom_name)) = ?', object.symptom_name.to_s.strip.downcase)
        if summaries.present? and summaries.count > 1
          @redirect_to = get_bulk_merge_symptom_summaries_path(bulk_ids: summaries.ids, from_edit: true, from_edit_object_id: object.id, return_to: @redirect_path)
        end
      end    

      if @redirect_to
        redirect_to @redirect_to
      else
        if params[:_add_another]
          redirect_to new_path(return_to: params[:return_to]), flash: {success: notice}
        elsif params[:_add_edit]
          redirect_to edit_path(id: @object.id, return_to: params[:return_to]), flash: {success: notice}
        else
          redirect_to back_or_index, flash: {success: notice}
        end
      end      
    end

    def get_object
      raise RailsAdmin::ObjectNotFound unless (object = @abstract_model.model.unscoped.find(params[:id]))
      @object = RailsAdmin::Adapters::ActiveRecord::AbstractObject.new(object)
    end

    def get_bulk_edit_treatment_summaries
      # The objects with the same name
      @objects = TreatmentSummary.where("id in (?)", params[:bulk_ids])
      params[:bulk_action] = 'bulk_edit_treatment_summaries'
      @pass_params = params.slice(:bulk_action, :bulk_ids, :model_name)

      @updated_id = params[:from_edit_object_id]
      flash[:notice] = nil

      render partial: 'rails_admin/treatment_summaries/bulk_edit_treatment_summaries'
    end

    def get_bulk_merge_symptom_summaries
      # The objects with the same name
      @objects = SymptomSummary.where("id in (?)", params[:bulk_ids])
      params[:bulk_action] = 'bulk_merge_symptom_summaries'
      @pass_params = params.slice(:bulk_action, :bulk_ids, :model_name)

      @updated_id = params[:from_edit_object_id]
      flash[:notice] = nil

      render partial: 'rails_admin/symptom_summaries/bulk_merge_symptom_summaries'
    end    
  end
end