class Admin::DiscountsController < AdminController
  def index
    @discounts = Discount.all
  end

  def show
    @discount = Discount.find(params[:id])
  end

  def new
    @discount = Discount.new
  end

  def edit
    @discount = Discount.find(params[:id])
  end

  def create
    @discount = Discount.new(params[:discount])

    if @discount.save
      redirect_to([:admin, @discount], :notice => 'Successfully created.')
    else
      render :action => "new"
    end
  end

  def update
    @discount = Discount.find(params[:id])

    if @discount.update_attributes(params[:discount])
      redirect_to([:admin, @discount], :notice => 'Successfully updated.')
    else
      render :action => "edit"
    end
  end

  def destroy
    @discount = Discount.find(params[:id])
    @discount.destroy

    redirect_to(admin_discounts_url)
  end
end
