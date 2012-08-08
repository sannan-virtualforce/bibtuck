class AddressesController < ApplicationController
  def new
    @is_first = (current_user.shipping_addresses.count == 0)
    @address = current_user.shipping_addresses.new
    @order_id = params[:order_id]
    render :layout => 'popup'
  end

  def edit
    @address = current_user.shipping_addresses.find(params[:id])
    render :layout => 'popup'
  end

  def create
    @address = current_user.shipping_addresses.new(params[:address])

    if @address.is_primary? && @address.valid?
      current_user.shipping_addresses.update_all 'is_primary = false'
    end

    if current_user.shipping_addresses.count == 0
      @address.is_primary = true
    end

    @address.save

    if params[:order_id]
      @order = current_user.orders.where(:id => params[:order_id], :is_complete => nil).first
      if @order
        @order.to_addr = @address
        @order.save(:validate => false)
      end
    end

    respond_to do |format|
      format.js
    end
  end

  def update
    @address = current_user.shipping_addresses.find(params[:id])
    @address.attributes = params[:address]
    if @address.valid?
      if @address.is_primary?
        current_user.shipping_addresses.where('id != ?', params[:id]).update_all 'is_primary = false'
      elsif current_user.primary_shipping_address.nil?
        @address.is_primary = true
      end
    end

    if @address.save
      flash[:notice] = "Address saved successfully."
      if params[:referrer]
        redirect_to params[:referrer]
      else
        redirect_to :back
      end
    else
      flash[:notice] = "There was an error saving your address."
      response.referrer = params[:referrer]
      render :new
    end
  end

  def destroy
    @address = current_user.shipping_addresses.find(params[:id])
    if @address
      @item_count = Item.where(:shipping_from_address => @address).count
      if @address.is_primary?
        flash[:popup_notice] = "You can't delete your default address"
      elsif @item_count > 0
        if params[:replace] && current_user.primary_shipping_address
          current_user.items.where(:shipping_from_address_id => @address.id)
            .update_all(:shipping_from_address_id => current_user.primary_shipping_address.id)
          @address.destroy
          flash[:notice] = "Address deleted successfully."
        else
          flash[:popup_notice] = {:id => :address_used, :item_count => @item_count, :address_id => @address.id}
        end
      else
        @address.destroy
        flash[:notice] = "Address deleted successfully."
      end
    end
    redirect_to :back
  end

  def set_as_primary
    @address = current_user.shipping_addresses.find(params[:id])
    if @address
      current_user.shipping_addresses.update_all 'is_primary = false'
      @address.update_attribute :is_primary, true
    end
    redirect_to :back
  end
end
