class UserConditionsController < ApplicationController

  before_filter :authenticate_user!, :find_user_condition
  skip_before_filter :check_profile, :only => [:create, :destroy]

  def create
    @user_condition = current_user.user_conditions.new(user_condition_params)
    unless @user_condition.save
      @error = 'User condition could not be saved.'
      render 'errors/error.js'
    end
    current_user.populate_patient_matches_both_ways if current_user.present?
  end

  def destroy
    @user_condition.destroy
    current_user.populate_patient_matches_both_ways if current_user.present?
  end

  def find_user_condition
    @user_condition = current_user.user_conditions.find(params[:id]) if params[:id].present?
  end

  def user_condition_params
    params.require(:user_condition).permit(:condition_id, :condition_name)
  end

end