class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  before_filter :store_location, :seo_conditions, :check_profile, :check_admin

  has_mobile_fu false

  def check_profile
    @excluding_controllers = ['devise/sessions']
    return if !current_user.is_a?(User) || @excluding_controllers.include?(params[:controller]) || current_user.finished_profile

    if current_user.main_condition_step.blank? || current_user.main_condition.blank?
      redirect_to select_main_condition_personal_profile_path
    elsif !current_user.basic_info_step.present?
      redirect_to basic_info_personal_profile_path; return
    elsif !current_user.finished_profile.present?
      redirect_to profile_photo_personal_profile_path; return
    end
  end

  def redirect_to_landing
    redirect_to landing_path, alert: 'You must be logged in to do that' if current_user.nil? && !%w(devise/sessions registrations main devise/passwords).include?(params[:controller])
  end

  def check_admin
    require_admin if request.path =~ /\/admin/
  end

  def require_admin
    if current_user.nil? || !current_user.is_admin?
      redirect_to '/'
    end
  end

  def after_sign_in_path_for(resource)
    if resource.is_a?(User)
      resource.update_logs unless resource.update_treatment_logs
    end
    if session[:previous_url]
      session[:previous_url] =~ /\?/ ? "#{session[:previous_url]}&signed_in=true" : "#{session[:previous_url]}?signed_in=true"
    else
      root_path(signed_in: true)
    end
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

  def store_location    
    session[:previous_url] = request.fullpath if current_user.nil? && request.fullpath['/users'] == nil && request.fullpath != '/landing' && request.fullpath != '/' && !request.xhr? && request.fullpath != '/posts/say_something'
  end  

  def render_left_menu
    # Override this method in the controller/action where you need it to return true/false
    # E.g., errors_controller.rb
    !%w(registrations devise/sessions devise/passwords my_click).include?(params[:controller]) && !view_context.after_sign_up_steps? && !['select_main_condition'].include?(params[:action]) && ((current_user && current_user.finished_profile?) || current_user.nil?)
  end
  
  def render_post_header
    # Override this method in the controller/action where you need it to return true/false
    # E.g., errors_controller.rb
    %w(home posts my_click reviews doctor_reviews).include?(params[:controller]) || %w(bookmarks my_topics).include?(params[:action])
  end

  def get_container_class
    # Override this method in the controller/action where you need it to return true/false
    # E.g., errors_controller.rb
    (params[:controller] == 'my_click') ? 'col-lg-12 col-md-12 col-sm-12 col-xs-12' : 'col-lg-9 col-md-9 col-sm-12 col-xs-12'
  end

  def render_dropdown
    return false if %w(bookmarks my_topics).include? params[:action]
    if params[:controller] == 'posts' && params[:action] == 'show'
      true
    else
      %w(home my_click personal_profiles doctor_reviews reviews).include?(params[:controller])
    end
  end

  def render_posts_filter
    return false if %w(bookmarks my_topics).include?(params[:action])
    return false if params[:action] == 'index' && params[:controller] == 'reviews'
    return false if params[:action] == 'index' && params[:controller] == 'main'
    true
  end

  def render_left_profile
    return false if %w(bookmarks my_topics).include?(params[:action])
    %w(personal_profiles settings messages notifications photos users).include? params[:controller]
  end

  def render_left_category
    %w(home posts my_click reviews doctor_reviews).include?  params[:controller]
  end
  
  def render_left_small_category
    true
    # ['all_topics', 'medical_topics', 'social_topics', 'fun_stuff', 'introductions'].include?(params[:post_type])
  end

  def seo_conditions
    if !request.xhr? && params[:controller] != 'users' && params[:condition_id].present? && params[:condition_id].is_number?
      slug = Condition.find_by_id(params[:condition_id]).try(:slug)
      redirect_to url_for(params.merge({condition_id: slug})) unless slug.nil?
    end
  end

  helper_method :render_left_menu, :render_post_header, :get_container_class, :render_dropdown, :render_posts_filter, :render_left_profile, :render_left_category, :render_left_small_category
end