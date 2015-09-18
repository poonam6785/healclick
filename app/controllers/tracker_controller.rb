class TrackerController < ApplicationController
  before_filter :find_tracking_date

  def treatments
  end

  def symptoms
  end

  def well_being
  end

protected

  def find_tracking_date
    @date = Time.parse(params.fetch(:date, Time.zone.now.to_date.to_s))
  end
end