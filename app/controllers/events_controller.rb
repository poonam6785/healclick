class EventsController < ApplicationController

  before_action :set_event, only: [:update, :show]

  def index
    @events = Event.all
  end

  def show
    respond_to do |format|
      format.js {}
    end
  end

  def create
    @event = current_user.events.new(event_params)
    respond_to do |format|
      if @event.save
        format.js {}
      else
        format.js {}
      end
    end
  end

  def update
    respond_to do |format|
      if @event.update(event_params)
        format.js {}
      end
    end
  end

  protected

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:body, :date)
  end

end
