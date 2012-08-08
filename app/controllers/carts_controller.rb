class CartsController < ApplicationController
  before_filter :authenticate_user!

  def update
    @item = Item.find(params[:item_id])
    return unless @item
    if Cart.item_in_any_cart?(@item)
      if params[:no_popup]
        flash[:popup_notice] = "Sorry, this item is currently in another member's shopping cart."
        redirect_to :back
      else
        render :text => "Sorry, this item is currently in another member's shopping cart."
      end
    else
      current_cart.add_item(@item)
      if params[:no_popup]
        flash[:popup_notice] = "This item has been added to your cart and will be reserved for #{Cart::CLEANUP_TIMEOUT_MIN} minutes."
        redirect_to cart_path
      else
        render :layout => false
      end
    end
  end

  def destroy
    @item = Item.find(params[:item_id])
    current_cart.remove_item(@item)
    if params[:cart_page] || params[:no_popup]
      flash[:popup_notice] = "Item has been removed."
      redirect_to cart_path
    else
      render :layout => false
    end
  end

  def show
    @cart = current_cart
    @recommended_items = @cart.items.map { |i| i.recommended_items(current_user) }.flatten.shuffle.first(3)
  end
end
