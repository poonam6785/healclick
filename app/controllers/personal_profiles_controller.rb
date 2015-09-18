class PersonalProfilesController < ApplicationController
  skip_before_filter :authenticate_user!, :check_profile, only: [:select_main_condition, :update, :basic_info, :my_health, :profile_photo, :check_main_condition]

  before_filter :redirect_to_landing, only: [:show, :my_health, :basic_info, :profile_photo]
  before_filter :set_finished_profile

  def show
    @user = User.find_by_username(params[:username])
    return redirect_to home_path if @user.blank?
    @message = Message.new(to_user_id: @user.id)
  end

  def symptoms_chart
    @user = User.find_by_id(params[:id])
    max_lab_value = @user.labs.find_max_current_value(@user)
    max_lab_value = 1 unless max_lab_value
    @symptoms_chart = LazyHighCharts::HighChart.new('HighStock') do |f|
      if params[:treatments]
        f.yAxis [{
          min: 0,
          max: 10,
          top: 0,
          height: 200,
          lineColor: 'transparent',
          gridLineWidth: 0,
          gridLineColor: 'transparent',
          labels: {enabled: false},
          title: {text: 'Treatments', style: {color: 'transparent'}},
        }, {
          min: 0, max: 10, top: 200, maxPadding: 0.5, height: 200, showLastLabel: true,
            labels: {formatter: 'function() {
                        var labels = {0: "None", 10: "Worst"};
                        label = labels[this.value] ? labels[this.value] : this.value
                        return label;
                      }'.js_code
            }
        }, {min: 0, max: max_lab_value, top: 450, height: 150, showFirstLabel: true, showLastLabel: true, labels: {formatter: 'function(){return this.value;}'.js_code}}]
        f.navigator margin: 100
        f.xAxis top: 130
      else
        f.yAxis min: 0, max: 10
      end
      @user.symptoms.find_each do |symptom|
        next if symptom.nil?
        data = symptom.symptom_logs.order('date ASC')
          .map {|v| [v.date.to_time.to_i * 1000, v.numeric_level]}
          .reject {|v| v.last.blank?}
        next if data.blank?
        series_params = {name: symptom.symptom, type: :spline, data: data, marker: {enabled: true, radius: 3}, shadow: true}
        series_params.merge!(yAxis: 1) if params[:treatments]
        f.series series_params
      end
      @user.well_being.tap do |well_being|
        next if well_being.blank?
        data = well_being.well_being_logs.order('date ASC')
          .map {|v| [v.date.to_time.to_i * 1000, v.numeric_level]}
          .reject {|v| v.last.blank?}
        next if data.blank?
        series_params = {name: well_being.symptom, type: :spline, data: data, marker: {enabled: true, radius: 3}, shadow: true}
        series_params.merge!(yAxis: 1) if params[:treatments]
        f.series series_params
      end

      # Treatments
      if params[:treatments]
        @user.treatments.each do |treatment|
          data = treatment.treatment_logs.where(take_today: true).order('date ASC')
          .map do |v|
            {
              x: v.date.to_time.to_i * 1000,
              y: 4,
              name: "#{l(v.date.to_time, format: :short)}",
              dose: v.try(:current_dose),
              level: v.try(:level).try(:humanize).try(:titleize)
            }
          end
          next if data.blank?
          f.series name: treatment.treatment, id: treatment.treatment, data: data, lineWidth: 0, marker: {enabled: true, radius: 5, symbol: 'circle', lineColor: 'rgba(68, 170, 213, 0.6)'}, shadow: true, yAxis: 0, tooltip: {headerFormat: '<b>{point.key}</b><br>', pointFormat: '{point.series.name}: {point.level}<br>{point.dose}'}, showInLegend: false, visible: false
        end
      end

      # Labs
      @user.labs.each do |lab|
        data = lab.lab_logs.not_blank.order('date ASC')
        .map do |l|
          {
            x: l.date.to_time.to_i * 1000,
            y: l.current_value.to_i,
          }
        end
        max_value = lab.lab_logs.not_blank.maximum('current_value')
        f.series name: lab.name, id: lab.name, data: data,  marker: {enabled: true, radius: 5, symbol: 'circle', lineColor: 'rgba(68, 170, 213, 0.6)'}, shadow: true, yAxis: 2, showInLegend: false, visible: false, max_value: max_value
      end
      f.series name: 'template', id: 'template', data: [],  marker: {enabled: true, radius: 5, symbol: 'circle', lineColor: 'rgba(68, 170, 213, 0.6)'}, shadow: true, yAxis: 2, showInLegend: false, visible: false unless @user.labs.any?

      # Events
      if (@user.id == current_user.try(:id) && !params[:time_series].present?) || (current_user.is_admin? && params[:from] == 'time_series_admin')
        data = []
        Event.unscoped do
          @user.events.order('date ASC').each do |event|
            data << {x: event.date.to_time.to_i * 1000, y: 6, color: '#2C6EB7', name: "#{l(event.date.to_time, format: :short)}", content: event.body}
          end
        end
      end

      f.series name: 'Events', id: 'events', data: data, marker: {enabled: true, symbol: 'circle', radius: 5}, color: '#2C6EB7', tooltip: {headerFormat: '<b>{point.key}</b><br>', pointFormat: '{point.content}'}, lineColor: 'rgba(68, 170, 213, 0.6)' if !params[:time_series].present? || (current_user.is_admin? && params[:from] == 'time_series_admin')

      f.legend enabled: true, maxHeight: 60
      f.exporting buttons: {
        contextButton: {enabled: false},
        exportButton: {text: 'Export', width: 50, x: -70},
        printButton: {text: 'Print', width: 50, x: 0}
      }
      f.rangeSelector inputPosition: {
        align: :left,
        y: 30,
        x: 25
      }, inputEditDateFormat: '%m-%d-%Y'
      f.scrollbar enabled: false
    end
    @symptoms_chart.html_options[:style] = 'height: 800px'
  end

  def activity
    @user = User.find_by_username(params[:username])
    @message = Message.new(to_user_id: @user.id)
    @comment = Comment.new
    activity_logs = ActivityLog.for_user(@user.id).group('activity_id').not_anonymous.recent.limit(300)
    replies = @user.posts.recently_created.limit(300)
    @activity_logs = (activity_logs + replies).sort_by{|r| -r.created_at.to_i}
    @activity_logs = Kaminari.paginate_array(@activity_logs).page(params[:page]).per(20)
  end

  def select_main_condition
    @user_condition = UserCondition.new
    @full_page_view = true
  end

  def profile_photo
    @full_page_view = true if !current_user.finished_profile
  end

  def basic_info
    if current_user.main_condition_id.present?
      @user_condition = UserCondition.new
      @symptom = Symptom.new
      @treatment = Treatment.new

      @full_page_view = true if view_context.after_sign_up_steps?
    else
      current_user.finished_profile = false
      current_user.save
      redirect_to :back, alert: 'You must select a diagnosis to continue.'
    end
  end

  def my_health
    @user_condition = UserCondition.new
    @symptom = Symptom.new
    @treatment = Treatment.new
    @remote = true
    @event = Event.new
    @events = current_user.events
    @p = (@events.count / 15.0).ceil
    @date = Time.now.in_time_zone
  end

  def update

    # After sign up step, when user can post his bio as a topic to the feed
    if view_context.after_sign_up_steps?
      if params[:commit] == 'as_topic' && !user_params[:bio].blank?
        intro_category = PostCategory.find_by_name 'Introductions'
        post = current_user.posts.create title: 'Introduction', content: user_params[:bio], post_category: intro_category
        post.conditions << current_user.main_condition
      end
    end

    current_user.update_attributes(user_params)

    unless current_user.finished_profile?
      cookies[:selected_community] = current_user.try(:main_condition).try(:name)
      current_user.settings.condition_id = current_user.try(:main_condition).try(:slug)
    end

    unless user_params[:profile_photo_file].present?
      Spawnling.new do
        previous_activity = ActivityLog.where(favorite_user_id: current_user.id, activity_type: 'User', created_at: 1.hour.ago..Time.now)
        if previous_activity.any?
          previous_activity.update_all created_at: Time.now, updated_at: Time.now
        else
          current_user.following_users.each do |fuser|
            fuser.following_user.activity_logs.create! activity: current_user, title: "updated their #{view_context.link_to 'Profile', profile_path(current_user.username)}", favorite_user_id: current_user.id, created_at: current_user.updated_at, updated_at: current_user.updated_at
          end
        end
      end
    end
    respond_to do |format|
      format.html do
        if user_params[:profile_photo_file].present?
          redirect_to crop_photo_personal_profile_path
        else
          if view_context.after_sign_up_steps?
            if request.referer =~ /profile_photo/
              redirect_to home_path, notice: 'Your profile was successfully updated'
            elsif request.referer =~ /basic_info/
              redirect_to profile_photo_personal_profile_path
            else
              redirect_to basic_info_personal_profile_path(commit: params[:commit]), notice: 'Your profile was successfully updated'
            end
          else
            if request.referer =~ /select_main_condition/ && params[:user][:main_condition_id].blank?
              flash[:error] = 'You must select a diagnosis to continue.'
              redirect_to select_main_condition_personal_profile_path
            else
              redirect_to home_path
            end
          end
        end
      end
      format.js do
        @user_condition = UserCondition.new
      end
    end
  end

  def crop_photo
    if request.patch?
      current_user.profile_photo.crop!(cropped_photo_params)
      if (30.minutes.ago..Time.zone.now).cover?(current_user.created_at)
        redirect_to my_health_personal_profile_path(finished_profile: true, medical_editor: :conditions)
      else
        redirect_to profile_path(current_user.username), notice: "Photo successfully updated"
      end
    end
  end

  def bookmarks
    params[:sort_by] ||= "posts.last_interaction_at desc"
    @posts = Post.where(id: current_user.post_followers.map(&:post_id)).page(params[:page]).per(20)
    @posts = @posts.order(params[:sort_by])
    @comment = Comment.new

    @treatment_review = TreatmentReview.new
    @treatment_review.treatment = Treatment.new(period: "#{1.month.ago.strftime("%m-%Y")} - Current", user: current_user, skip_review_update: true)
    @doctor_review = DoctorReview.new
    @doctor_review.doctor = current_user.doctors.new

    respond_to do |format|
      format.html
      format.js
    end
  end

  def get_container_class
    if @full_page_view
      'col-lg-12 col-md-12 col-sm-12 col-xs-12'
    else
      super
    end
  end

  def my_topics
    params[:sort_by] ||= 'posts.last_interaction_at desc'
    type = case params[:target]
             when 'Post'
               'Post'
             when 'Review'
               'Review'
             else
               nil
           end
    @posts = current_user.posts.not_tracking_updates.not_activity_reply
    @posts = @posts.by_type(type) if type
    @posts = @posts.order(params[:sort_by])
    @posts = @posts.page(params[:page]).per(20)
    @treatment_review = TreatmentReview.new
    @treatment_review.treatment = Treatment.new(period: "#{1.month.ago.strftime("%m-%Y")} - Current", user: current_user, skip_review_update: true)
    @doctor_review = DoctorReview.new
    @doctor_review.doctor = current_user.doctors.new
    @comment = Comment.new
  end

private
  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    return {} if params[:user].blank?
    params[:user].permit(:main_condition_id, :main_condition_diagnosed_at, :main_condition_not_officially_diagnosed, :first_name, :last_name, :birth_date, :bio, :gender, :location,
                         :profile_photo_file, :basic_info_step, :main_condition_step, :my_health_step, :finished_profile,
                         :country_id, :zipcode, :city, :state,
                         condition_ids: [], symptom_names: [], symptom_levels: [],
                         treatment_names: [], treatment_start_years: [], treatment_start_months: [],
                         treatment_end_years: [],  treatment_end_months: [])
  end

  def cropped_photo_params
    params[:cropped_photo].permit(:crop_x, :crop_y, :crop_w, :crop_h)
  end

  def set_finished_profile
    if params[:finish_profile]
      current_user.update_attributes(finished_profile: true)
    end
  end
end