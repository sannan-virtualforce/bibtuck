class Admin::FlaggedItemsController < AdminController

  def index
    @flagged_items = FlaggedItem.all
  end

  def show
    @flagged_item = FlaggedItem.find(params[:id])
  end

  def new
    @flagged_item = FlaggedItem.new
  end

  def edit
    @flagged_item = FlaggedItem.find(params[:id])
  end

  def create
    @flagged_item = FlaggedItem.new(params[:flagged_item])

    if @flagged_item.save
      redirect_to([:admin, @flagged_item], :notice => 'Successfully created.')
    else
      render :action => "new"
    end
  end

  def update
    @flagged_item = FlaggedItem.find(params[:id])

    if @flagged_item.update_attributes(params[:flagged_item])
      redirect_to([:admin, @flagged_item], :notice => 'Successfully updated.')
    else
      render :action => "edit"
    end
  end

  def destroy
    @flagged_item = FlaggedItem.find(params[:id])
    @flagged_item.destroy

    redirect_to(admin_flagged_items_url)
  end

end
