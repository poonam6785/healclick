class ConditionsController < ApplicationController

  skip_before_filter :check_profile, :only => [:autocomplete]

  def autocomplete
    @conditions = []
    @conditions = Condition.search(params[:query]) if params[:query].length >= 3
    render json: @conditions.map(&:name).compact.map(&:to_s).map(&:titleize).to_json
  end

end