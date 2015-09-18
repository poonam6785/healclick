class NoindexRulesController < ApplicationController
  before_action :require_admin

  def destroy
    NoindexRule.find(params[:id]).destroy
  end

  def create
    NoindexRule.create noindex_params
  end

  private

  def noindex_params
    params.require(:noindex_rule).permit(:url)
  end

end