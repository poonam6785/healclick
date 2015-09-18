class MyClickController < ApplicationController

  before_filter :authenticate_user!

  def index
    params[:sort_by] ||= 'posts.created_at desc'

    @post  = current_user.posts.new
    @comment  = Comment.new

    @posts = Post.all.not_anonymous.not_my(current_user.id)
    @posts = @posts.followed_by(current_user).order(params[:sort_by]).page(params[:page]).per(20)

    @activity = current_user.activity_logs.from_favorite_users
    @combined_records = (@activity + @posts).sort_by{|r| -r.created_at.to_i}

    if @combined_records.present?
      @combined_records = if @combined_records.respond_to?(:page)
        @combined_records.page(params[:page]).per(20)
      else
        Kaminari.paginate_array(@combined_records).page(params[:page]).per(20)
      end
    end

    @treatment_review = TreatmentReview.new
    @treatment_review.treatment = Treatment.new(period: "#{1.month.ago.strftime("%m-%Y")} - Current", user: current_user, skip_review_update: true)
    if current_user
      @doctor_review = DoctorReview.new
      @doctor_review.doctor = current_user.doctors.new 
    end
    respond_to do |format|
      format.js
      format.html
    end
  end

end