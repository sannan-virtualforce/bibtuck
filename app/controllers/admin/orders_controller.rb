class Admin::OrdersController < AdminController

  def index
    @orders = Order.where(:is_complete => true).order('created_at DESC')
  end

  def show
    @order = Order.find(params[:id])
  end

  def edit_address
    case params[:type]
    when 'from'
      @target = OrderItem.find(params[:id])
      @address = @target.from_addr
      @type = 'from'
    when 'to'
      @target = Order.find(params[:id])
      @address = @target.to_addr
      @type = 'to'
    end
    render :layout => 'popup'
  end

  def update_address
    @address = Address.new(params[:address])
    case params[:type]
    when 'from'
      @target = OrderItem.find(params[:id])
      @target.from_addr = @address
    when 'to'
      @target = Order.find(params[:id])
      @target.to_addr = @address
    end
    if @target.save
      flash[:notice] = 'Address saved successfully.'
    else
      flash[:notice] = 'There was error saving address.'
    end
    if params[:referrer]
      redirect_to params[:referrer]
    else
      redirect_to :back
    end
  end

end
