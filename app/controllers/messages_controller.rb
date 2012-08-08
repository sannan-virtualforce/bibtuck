class MessagesController < ApplicationController
  before_filter :authenticate_user!

  def new
    @user = User.find(params[:user_id])
    @message = current_user.messages.new
    @message.to = @user
    render :layout => false
  end

  def destroy
    # Only hide recipient of this message
    @message_recipient = MessageRecipient.where(:id => params[:id], :receiver_id => current_user.id).first
    current_user.hide_stream_with(@message_recipient.message.sender)
    flash[:notice] = "Message deleted successfully."
    redirect_to :back
  end

  def bulk_update
    @message_recipients = MessageRecipient.where(:id => params[:message_recipient_ids])
    messages = @message_recipients.map(&:message).flatten

    case params[:commit]
    when 'Mark as Read'
      @message_recipients.map(&:view!)
    when 'Mark as Unread'
      @message_recipients.map { |mr| mr.update_attribute(:state, :unread) }
    when 'Delete'
      @message_recipients.each do |mr|
        current_user.hide_stream_with(@mr.message.sender)
      end
    end

    flash[:notice] = "Messages updated successfully."
    redirect_to :back
  end

  def update
    @message = Message.find(params[:id])
    @message.attributes = params[:message]

    if @message.save
      flash[:notice] = "Message updated successfully."
      redirect_to :back
    end
  end

  def reply
    original_message = Message.find(params[:id])
    @message = original_message.reply
    render :layout => false
  end

  def create
    @to_user = if params[:message][:receiver_id]
                 User.find(params[:message][:receiver_id])
               else
                 User.find(params[:user_id])
               end

    @message = current_user.messages.new(params[:message])

    # TODO: Why?
    if original = Message.find_by_id(params[:message][:original_message_id])
      @message.to = original.sender
      @message.original_message = original
    else
      @message.to = @to_user
    end
    @message.deliver

    recipient = @message.to.first
    flash[:notice] = "Message to #{recipient.full_name} sent."
    redirect_to :back
  end

  def sent
    @user = User.find(params[:user_id])
    @message_recipients = @user.sent_messages.visible.map(&:recipients).flatten
  end

  def index
    @user = User.find(params[:user_id])
    @message_recipients = @user.received_messages.visible.includes(:message)
  end

  def show
    @user = User.find(params[:user_id])
    @message = Message.find(params[:id])

    @stream = @user.message_stream_with(@message.sender)
    mr = @message.recipients.where(:receiver => @user).first
    mr.view!  if mr && mr.unread?
  end
end
