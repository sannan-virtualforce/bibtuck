class Admin::ItemsController < AdminController

  def index
    @items = Item.all
  end

  def show
    @item = Item.find(params[:id])
  end

  def new
    @item = Item.new
  end

  def edit
    @item = Item.find(params[:id])
  end

  def create
    @item = Item.new(params[:item])

    if @item.save
      redirect_to([:admin, @item], :notice => 'Successfully created.')
    else
      render :action => "new"
    end
  end

  def update
    @item = Item.find(params[:id])

    if @item.update_attributes(params[:item])
      redirect_to([:admin, @item], :notice => 'Successfully updated.')
    else
      render :action => "edit"
    end
  end

  def change_state
    @item = Item.find(params[:id])
    state = params[:state]
    case state
    when 'open'
      if @item.listed?
        @item.unbib!
        flash[:notice] = 'Status changed'
      end
    when 'listed'
      if @item.open?
        @item.bib
        flash[:notice] = 'Status changed'
      end
    when 'shipped'
      if @item.shipping? && @item.order_item && @item.order_item.pending?
        @item.order_item.mark_as_shipped
        flash[:notice] = 'Status changed'
      end
    when 'delivered'
      if @item.shipping? && @item.order_item && (@item.order_item.shipped? || @item.order_item.pending?)
        @item.order_item.mark_as_delivered
        flash[:notice] = 'Status changed'
      end
    when 'canceled'
      if @item.shipping? && @item.order_item && (@item.order_item.shipped? || @item.order_item.pending?)
        @item.order_item.mark_as_canceled
        flash[:notice] = 'Status changed'
      end
    end
    redirect_to :back
  end

  def destroy
    @item = Item.find(params[:id])
    @item.destroy

    redirect_to(admin_items_url)
  end

end
