class SettingsController < ApplicationController
  before_filter :redirect_to_landing, only: [:index]
  before_filter :authenticate_user!

  def index
    if request.patch?
      if current_user.update_attributes(user_params)
        flash.now[:notice] = 'Settings successfully updated'
        sign_in(current_user, :bypass => true)
      else
        render "index"
      end
    end
  end

  def set
    params[:settings].each do |key, value|
      current_user.settings.send("#{key}=", value)
    end
    @flash = params[:flash] != 'false'
    respond_to do |format|
      format.js
      format.html {head :ok}
    end
  end

  def user_params
    params.require(:user).permit(
      :email, :password, :password_confirmation, :profile_is_public, :photo_is_public, :age_is_public, :gender_is_public,:bio_is_public, :main_condition_is_public, :followed_users_is_public,:following_users_is_public, :gets_email_for_private_message, :gets_email_for_follower,:gets_email_for_helpful, :gets_email_when_mentioned, :gets_email_when_reply,:gets_email_when_comment, :gets_email_when_comment_after , :gets_email_when_luv, :gets_email_when_luv_post, :gets_email_when_subscribed, :privacy, :tracking_email, :email_digest_for_private_message, :email_digest_for_follower, :email_digest_for_helpful, :email_digest_when_mentioned, :email_digest_when_reply, :email_digest_when_comment, :email_digest_when_comment_after, :email_digest_when_luv, :email_digest_when_luv_post, :email_digest_when_subscribed)
  end

end