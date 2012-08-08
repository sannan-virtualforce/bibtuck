class OrdersController < ApplicationController

  before_filter :authenticate_user!

  def new
    @user = current_user
    if params[:discount_code] || params[:new_address]
      @order = @user.orders.where(:is_complete => nil).first
    else
      @user.orders.where(:is_complete => nil).each do |unfinished_order|
        unfinished_order.destroy
      end
    end

    unless @order
      @order = @user.orders.new(params[:order])
      @order.to_addr = @user.primary_shipping_address if @user.primary_shipping_address.present?
      current_cart.items.each do |item|
        order_item = @order.order_items.build(:order => @order, :item => item)
        order_item.from_addr = item.shipping_from_address
      end
      @order.set_totals
    end

    if @order.total_bucks > @user.buck_balance
      flash[:notice] = "You do not have enough bucks to purchase."
      redirect_to cart_path(current_cart)
    end

    if params[:discount_code]
      if @order.discount.blank?
        code = Discount.find_by_code(params[:discount_code])
        unless code && code.still_valid?
          flash[:notice] = 'Promo Code not Found.'
        else
          if code.min_amount.to_i > 0 && @order.bucks_total < code.min_amount
            flash[:notice] = "Promo Code can only be used on orders over #{code.min_amount} bucks."
          else
            @order.discount = code
            flash[:notice] = "Discount applied."
          end
        end
      end
    end

    if params[:new_address]
      shipping_address = current_user.shipping_addresses.create(params[:new_address])
      @order.to_addr = shipping_address
    end

    if @order.save(:validate => false)
      if @order.amount_in_cents > 0
        wepay = WePay.new(WEPAY_OPTIONS[:client_id], WEPAY_OPTIONS[:secret], WEPAY_OPTIONS[:use_stage])
        checkout_params = {
          :account_id => WEPAY_OPTIONS[:account_id],
          :amount => @order.amount_in_cents/100,
          :short_description => "Payment for Order No. #{@order.id}",
          :fee_payer => :Payee,
          :type => :SERVICE,
          :mode => :iframe,
          :redirect_uri => complete_order_url(@order)
        }
        @wepaycheckout = wepay.call('/checkout/create', WEPAY_OPTIONS[:access_token], checkout_params)
        @order.update_attribute :wepay_checkout_id, @wepaycheckout['checkout_id']
      end
    else
      flash[:notice] = "There was an error generating your order"
      redirect_to cart_path(current_cart)
    end
  end

  def setaddress
    @user = current_user
    @order = @user.orders.where(:id => params[:id], :is_complete => nil).first
    @address = @user.shipping_addresses.where(:id => params[:address_id]).first
    if @order && @address
      @order.to_addr = @address
      @order.save(:validate => false)
      render :json => @address
    else
      render :json => { :error => 'Error setting address' }, :status => :unprocessable_entity
    end
  end

  def express
    @user = current_user
    @order = @user.orders.where(:id => params[:id], :is_complete => nil).first
    if @order
      res = EXPRESS_GATEWAY.setup_purchase(@order.amount_in_cents,
        :ip                => request.remote_ip,
        :return_url        => complete_order_url(@order),
        :cancel_return_url => root_url
      )
      redirect_to EXPRESS_GATEWAY.redirect_url_for(res.token)
    else
      flash[:notice] = "There was an error processing your order"
      redirect_to new_order_path
    end
  end

  def complete
    @user = current_user
    @order = @user.orders.find(params[:id])
    if @order
      unless @order.is_complete?
        @order.ip_address = request.ip
        if params[:checkout_id]
          # WePay complete
          if params[:checkout_id].to_i == @order.wepay_checkout_id
            wepay = WePay.new(WEPAY_OPTIONS[:client_id], WEPAY_OPTIONS[:secret], WEPAY_OPTIONS[:use_stage])
            response = wepay.call('/checkout', WEPAY_OPTIONS[:access_token], {
              checkout_id: params[:checkout_id]
            })
            if %w(authorized reserved captured settled).include? response['state']
              @order.after_purchase
              current_cart.clear!
            else
              flash[:notice] = 'There was an error with your payment.'
              redirect_to new_order_path
            end
          else
            flash[:notice] = "There was an error with you payment"
            redirect_to new_order_path
          end
        elsif params[:token]
          # PayPal complete
          @order.express_token = params[:token]
          @order.express_payer_id = params[:PayerID]
          @order.wepay_checkout_id = nil
          @order.purchase
          current_cart.clear!
        else
          # Free order
          if @order.amount_in_cents == 0
            @order.after_purchase
            current_cart.clear!
          else
            redirect_to new_order_path
          end
        end
      end
    else
      flash[:notice] = "Could not find specified order."
      redirect_to cart_path(current_cart)
    end
  end
end
