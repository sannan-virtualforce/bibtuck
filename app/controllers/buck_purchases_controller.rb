class BuckPurchasesController < ApplicationController
  before_filter :authenticate_user!

  def new
    @buck_purchase = BuckPurchase.new(params[:buck_purchase])
    @ref_page = params[:ref_page]
    respond_to do |format|
      format.html { render :layout => 'popup' }
      format.js
    end
  end

  def not_enough
    @buck_purchase = BuckPurchase.new(params[:buck_purchase])
    @item = Item.find_by_id(params[:item_id])
    @difference = current_cart.amount_needed(current_user, @item)
    @ref_page = :not_enough
    render :layout => 'popup'
  end

  def select_payment_option
    buck_params = params[:buck_purchase] || {}
    buck_params[:bucks] = buck_params[:bucks] == 'Other' ? params[:bucks_other] : buck_params[:bucks]
    @amount = BuckPurchase.bucks_to_cents(buck_params[:bucks])
    @return_params = {
      'bucks' => buck_params[:bucks].to_i,
      'item_id' => params[:item_id],
      'ref_page' => params[:ref_page]
    }
    if @amount > 0
      @amount /= 100.0
      wepay = WePay.new(WEPAY_OPTIONS[:client_id], WEPAY_OPTIONS[:secret], WEPAY_OPTIONS[:use_stage])
      wepay_params = {
        :account_id => WEPAY_OPTIONS[:account_id],
        :amount => @amount,
        :short_description => "Buying #{buck_params[:bucks]}.",
        :fee_payer => :Payee,
        :type => :SERVICE,
        :mode => :iframe,
        :redirect_uri => complete_buck_purchases_url(@return_params)
      }
      @wepaycheckout = wepay.call('/checkout/create', WEPAY_OPTIONS[:access_token], wepay_params)
      render :layout => 'popup'
    else
      render :text => "Wrong amount."
    end
  end

  def express
    amount = BuckPurchase.bucks_to_cents(params[:bucks].to_i)
    if amount > 0
      return_params = {
        'bucks' => params[:bucks],
        'item_id' => params[:item_id],
        'ref_page' => params[:ref_page]
      }
      res = EXPRESS_GATEWAY.setup_purchase(amount,
        :ip                => request.remote_ip,
        :return_url        => complete_buck_purchases_url(return_params),
        :cancel_return_url => root_url
      )
      redirect_to EXPRESS_GATEWAY.redirect_url_for(res.token)
    else
      flash[:notice] = "Error processing your payment."
      redirect_to case params[:ref_page]
      when 'not_enough'
        cart_path(current_user)
      when 'q_and_a'
        page_path('q_and_a')
      when 'my_profile'
        user_path(current_user)
      else
        items_path
      end
    end
  end

  def complete
    @user = current_user
    @buck_purchase = BuckPurchase.new(:bucks => params[:bucks])
    @buck_purchase.user = @user
    @buck_purchase.ip_address = request.ip
    if params[:checkout_id]
      # WePay complete
      @buck_purchase.wepay_checkout_id = params[:checkout_id]
    elsif params[:token]
      # PayPal complete
      @buck_purchase.express_token = params[:token]
      @buck_purchase.express_payer_id = params['PayerID']
      @buck_purchase.wepay_checkout_id = nil
    else
      flash[:notice] = 'There was an error with your payment.'
      redirect_to cart_path(@user)
      return
    end

    if @buck_purchase.save
      if @buck_purchase.wepay_checkout_id
        # wepay
        wepay = WePay.new(WEPAY_OPTIONS[:client_id], WEPAY_OPTIONS[:secret], WEPAY_OPTIONS[:use_stage])
        response = wepay.call('/checkout', WEPAY_OPTIONS[:access_token], {
          checkout_id: params[:checkout_id]
        })
        if %w(authorized reserved captured settled).include? response['state']
          @buck_purchase.after_purchase
          flash[:popup_notice] = {:id => 'buck_purchase_ok', :amount => @buck_purchase.bucks}
        else
          flash[:notice] = 'There was an error with your payment.'
        end
      else
        # paypal
        if @buck_purchase.purchase
          flash[:popup_notice] = {:id => 'buck_purchase_ok', :amount => @buck_purchase.bucks}
        else
          flash[:notice] = "There was an error making the purchase."
        end
      end
    else
      flash[:notice] = "There was an error with your order."
    end

    case params[:ref_page]
    when 'not_enough'
      if params[:item_id]
        item = Item.find_by_id(params[:item_id])
        if item
          if current_user.can_afford?(item) && !Cart.item_in_any_cart?(item)
            current_cart.add_item(item)
          else
            redirect_to item
            return
          end
        end
      end
      redirect_to cart_path(current_user)
    when 'q_and_a'
      redirect_to page_path('q_and_a')
    when 'my_profile'
      redirect_to current_user
    else
      redirect_to items_path
    end
  end
end
