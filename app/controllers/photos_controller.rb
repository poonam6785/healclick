class PhotosController < ApplicationController
  before_filter :redirect_to_landing, only: [:index]
  before_filter :authenticate_user!, :load_user
  before_filter :load_photo, except: :show

  def index
    @photos = @user.photos.order("created_at desc").page(params[:page]).per(9)
    @photo = current_user.photos.new
  end

  def show
    @photo = Photo.find(params[:id])
    @comment = current_user.comments.new
  end

  def edit
    @photo = current_user.photos.find(params[:id])
    respond_to do |format|
      format.html
      format.js { @remote = true }
    end
  end

  def update
    title = (params[:cropped_photo] || params[:photo])[:title]
    @photo = current_user.photos.find(params[:id])
    if title.present?
      @photo.title = title
      @photo.description = title
    end
    @photo.save!
    redirect_to user_photo_path(@photo.user, @photo)
  end

  def set_as_profile
    @photo.update_attributes(type: 'CroppedPhoto')
    @photo.attachment.reprocess!(:small)
    current_user.update_attributes(profile_photo_id: @photo.id)
    redirect_to user_photos_path(current_user), notice: 'Profile photo successfully updated'
  end

  def create
    @photo = current_user.photos.new(photo_params)
    if @photo.save
      redirect_to user_photos_path(current_user), notice: 'Photo successfully uploaded'
    end
  end

  def load_user
    @user = User.find(params[:user_id]) if params[:user_id].present?
    @user ||= current_user
  end

  def load_photo
    @photo = @user.photos.find(params[:id]) if params[:id].present?
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def photo_params
    params.require(:photo).permit(:attachment, :description)
  end

  def destroy
    @photo = current_user.photos.find(params[:id])
    
    if @photo.present?
      if @photo != current_user.profile_photo
        @photo.destroy
        redirect_to user_photos_path(current_user), notice: 'Photo successfully removed'        
      else
        flash[:error] = 'Please select another profile photo before removing this photo'
        redirect_to user_photos_path(current_user)
      end
    end
  end

end
