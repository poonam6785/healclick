class SystemSettingsController < ApplicationController
  before_filter :require_admin

  def create
    update_settings
    redirect_to_desired_location
  end

  def update
    update_settings
    redirect_to_desired_location
  end

  def points_save
    unless params[:settings].blank?
      params[:settings].each do |key, value|
        ActionPoints.send("#{key}=".to_param, value)
      end
    end
    redirect_to :back, notice: 'Settings updated successfully'
  end

protected
  def update_settings
    settings_params.each do |key, value|
      SystemSetting.get(key).update_attributes(:value => value)
    end
  end

  def redirect_to_desired_location
    redirect_to params.fetch(:redirect_to, home_path), notice: 'Settings updated successfully'
  end

  def settings_params
    params.require(:system_settings)
  end
end
