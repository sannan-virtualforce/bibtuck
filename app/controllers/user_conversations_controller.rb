class UserConversationsController < ApplicationController
  include ApplicationHelper
  before_filter :authenticate_user!

  def index
    @user = current_user
    @conversations = @user.user_conversations.where(:deleted => nil)
      .joins(:messages)
      .select('user_conversations.id, user_conversations.user_id, user_conversations.conversation_id, user_conversations.read, user_conversations.deleted, max(messages.created_at)')
      .group('user_conversations.id, user_conversations.user_id, user_conversations.conversation_id, user_conversations.read, user_conversations.deleted')
      .order('max(messages.created_at) DESC')
  end

  def show
    @conversation = current_user.user_conversations.where(:id => params[:id]).first
    if @conversation.present?
      @conversation.update_attributes :read => true
      @recipient = @conversation.users.select {|u| u != current_user}.first
      @messages = @conversation.messages.reorder('created_at')
    else
      redirect_to [current_user, :conversations]
    end
  end

  def edit
    @user = User.find params[:user_id]
    @to_user = User.find params[:to_user_id]
    @conversation = @user.convo_with(@to_user)
    render :layout => false, :template => '/user_conversations/new'
  end

  def new
    redirect_to users_path unless current_user

    @user = User.find params[:user_id]
    @to_user = User.find params[:to_user_id]
    @conversation = @user.user_conversations.build
    @conversation.build_conversation.messages.build
    render :layout => false
  end

  def create
    redirect_to users_path unless current_user

    @conversation = UserConversation.new params[:user_conversation]
    @conversation.user = current_user
    @conversation.conversation.messages.first.user = current_user
    @conversation.save!
    redirect_to :back
  end

  def destroy
    @conversation = current_user.user_conversations.find(params[:id])
    if @conversation.present?
      @conversation.update_attributes :deleted => true
    end
    redirect_to user_conversations_path
  end

  def mark_as_read
    @conversation = UserConversation.find params[:id]
    @conversation.update_attributes :read => true
    redirect_to user_conversation_path(current_user, @conversation)
  end

  def mark_as_unread
    @conversation = UserConversation.find params[:id]
    @conversation.update_attributes :read => false
    redirect_to user_conversation_path(current_user, @conversation)
  end

  def bulk_update
    selection = params[:conversation_id]
    selection.each do |conversation_id|
      conversation = current_user.user_conversations.find(conversation_id)
      if conversation.present?
        case params[:bulk_action]
        when 'mark_read'
          conversation.update_attributes :read => true
        when 'mark_unread'
          conversation.update_attributes :read => false
        when 'delete'
          conversation.update_attributes :deleted => true
        end
      end
    end
    redirect_to :back
  end

  def update
    @conversation = current_user.user_conversations.find(params[:id])
    @body = params[:body] || params[:user_conversation][:conversation_attributes][:messages_attributes]["0"][:body]
    @conversation.conversation.messages.create!({
      :user => current_user,
      :body => @body
    })
    redirect_to :back
  end
end
