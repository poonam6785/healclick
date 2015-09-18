class MessagesController < ApplicationController
  before_filter :redirect_to_landing, only: [:index]
  before_filter :authenticate_user!, :find_message

  def index
    @messages = current_user.received_messages.undeleted_by_recipient.newest.order('created_at desc').page(params[:page]).per(20)
  end

  def mark_all_as_read
    current_user.received_messages.unread.map(&:read!)
    redirect_to messages_path, notice: 'All messages marked as read'
  end

  def delete_all
    current_user.received_messages.map(&:delete_by_recipient!)
    redirect_to messages_path, notice: 'All messages were deleted'
  end

  def delete_all_sent
    current_user.sent_messages.map(&:delete_by_sender!)
    redirect_to sent_messages_path, notice: 'All messages were deleted'
  end

  def sent
    @messages = current_user.sent_messages.undeleted_by_sender.order("created_at desc").page(params[:page]).per(20)
  end

  def show
    @message.read! if @message.to_user_id == current_user.id
    opponent = current_user.id == @message.from_user_id ? @message.to_user : @message.from_user
    @messages = current_user.all_messages_with(opponent).undeleted_by_recipient.undeleted_by_sender
    @messages = Kaminari.paginate_array(@messages).page(params[:page]).per(5)
    @reply_message = current_user.sent_messages.new(reply_to_message: @message, to_user: opponent)
  end

  def new
    @message = current_user.sent_messages.new
  end

  def create
    @message = current_user.sent_messages.new(message_params)
    @message.is_read = false
    @to_user = @message.to_user

    if @to_user.blank?
      @composer_error = true
      flash.now[:error] = "Recipient doesn't seem to be a valid user. Please check and try again"
      render :new; return
    end

    if @message.save
      if params[:from_profile]
        redirect_to profile_path(@message.to_user.username), notice: 'Message successfully sent!'; return        
      else
        redirect_to message_path(@message), notice: 'Message successfully sent!'; return        
      end
    end
  end

  def destroy
    if @message.to_user == current_user
      @message.delete_by_recipient!
      redirect_to messages_path, notice: 'Message successfully removed'      
    elsif @message.from_user == current_user
      @message.delete_by_sender!
      redirect_to sent_messages_path, notice: 'Message successfully removed'
    end
  end

  def find_message
    if params[:id]
      @message = current_user.received_messages.find(params[:id]) rescue nil
      @message ||= current_user.sent_messages.find(params[:id]) rescue nil

      redirect_to messages_path if @message.blank?
    end
  end

  def message_params
    params.require(:message).permit(:subject, :to_user_id, :to_user_username, :content, :reply_to_message_id)
  end

end