class Admin::SubscribersController < AdminController

  def index
    @subscribers = Subscriber.all
  end

  def show
    @subscriber = Subscriber.find(params[:id])
  end

  def new
    @subscriber = Subscriber.new
  end

  def edit
    @subscriber = Subscriber.find(params[:id])
  end

  def create
    @subscriber = Subscriber.new(params[:subscriber])

    if @subscriber.save
      redirect_to([:admin, @subscriber], :notice => 'Successfully created.')
    else
      render :action => "new"
    end
  end

  def update
    @subscriber = Subscriber.find(params[:id])

    if @subscriber.update_attributes(params[:subscriber])
      redirect_to([:admin, @subscriber], :notice => 'Successfully updated.')
    else
      render :action => "edit"
    end
  end

  def destroy
    @subscriber = Subscriber.find(params[:id])
    @subscriber.destroy

    redirect_to(admin_subscribers_url)
  end

  def export
    @subscribers = Subscriber.all

    respond_to do |format|
      format.csv { send_data @subscribers.to_csv }
    end
  end

end
