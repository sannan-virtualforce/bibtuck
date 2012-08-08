class SubscribersController < ApplicationController
  layout "sessions"

  skip_before_filter :redirect_to_sign_in_page

  def show
  end

  def new
    @subscriber = Subscriber.new
  end

  def create
    @subscriber = Subscriber.new(params[:subscriber])

    if @subscriber.save
      redirect_to(subscriber_path, :notice => 'Subscriber was successfully created.')
    else
      render :action => "new"
    end
  end

end
