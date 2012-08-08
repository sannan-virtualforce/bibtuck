class FeedbackMessagesController < ApplicationController
  def new
    @feedback_message = FeedbackMessage.new
    render :layout => false
  end

  def create
    @feedback_message = FeedbackMessage.new(params[:feedback_message])
    if @feedback_message.valid?
      @feedback_message.send_to_admin!
      flash[:popup_notice] = { :id => 'feedback_thankyou', :popupwidth => 400 }
    else
      flash[:popup_notice] = 'There was an error submitting your feedback.'
    end
    redirect_to root_path
  end
end
