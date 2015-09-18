class NotificationsController < ApplicationController
  before_filter :redirect_to_landing, only: [:index]
  before_filter :authenticate_user!, :find_notification
  
  def mark_all_as_read
    current_user.received_notifications.unread.map(&:read!)
    respond_to do |format|
      format.html { redirect_to notifications_path, notice: 'All notifications marked as read' }
      format.js
    end
  end

  def delete_all
    current_user.received_notifications.map(&:destroy)
    redirect_to notifications_path, notice: 'All notifications successfully deleted'
  end

  def index
    @notifications = current_user.received_notifications.recent.page(params[:page]).per(20)
  end

  def show
    @notification.read!
    respond_to do |format|
      format.js {render 'show.js'}
      format.html { redirect_to @notification.target_url unless @notification.target_url.blank?}
    end
  end

  def destroy
    @notification.destroy
    redirect_to notifications_path, notice: 'Notification successfully removed'
  end

  def find_notification
    if params[:id]
      @notification = current_user.received_notifications.find(params[:id]) rescue nil
      redirect_to notifications_path if @notification.blank?
    end
  end
end