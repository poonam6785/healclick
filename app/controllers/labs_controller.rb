class LabsController < ApplicationController

  before_filter :authenticate_user!, :find_tracking_date
  skip_before_filter :check_profile, :only => [:autocomplete, :batch_create]

  def autocomplete
    if params[:query].length >= 3
      labs = LabSummary.search(params[:query]).with_labs.by_count
    else
      labs = []
    end

    render json: labs.try(:names_with_counts)
  end

  def update
    current_user.labs.find(params[:id]).update_attributes(lab_params.merge(date: @date))
  end

  def batch_create
    @errors = nil
    labs = []
    lab_params[:name].split(',').reverse.each do |lab|
      lab = Lab.new name: lab, user_id: current_user.id, date: @date
      if lab.valid?
        lab.save
        labs << lab
      else
        @errors = lab.errors.try(:[], :lab).try(:first) if @errors.nil?
      end
    end
  end

  def batch_delete
    current_user.labs.where(id: params[:ids].split(',')).destroy_all
  end

  def change_date

  end

  private

  def lab_params
    params.require(:lab).permit(:name, :current_value, :unit)
  end

  def find_tracking_date
    @date = params[:date].present? ? Date.parse(params[:date]) : Time.zone.now.to_date.to_s
  end

end