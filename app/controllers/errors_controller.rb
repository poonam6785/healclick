class ErrorsController < ApplicationController
  def render_left_menu
    false
  end

  def get_container_class
    'col-md-12'
  end

  def render_post_header
    false
  end
end