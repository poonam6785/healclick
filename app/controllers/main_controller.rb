class MainController < ApplicationController
  before_filter :save_referrer
  layout "landing"
  before_filter :require_admin, only: [:run_digest]

  def index
    if current_user.is_a?(User)
      redirect_to home_path
    else
      @resource = User.new
    end
  end

  def run_digest
    %x[rake notification:digest]
    redirect_to :back, notice: 'Check your emails!'
  end

  private

  def save_referrer
    session['referrer'] = request.env["HTTP_REFERER"] if session['referrer'].blank?
  end
end