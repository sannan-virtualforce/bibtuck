class CarrierPickupsController < ApplicationController
  before_filter :authenticate_user!

  def new
    @item = Item.find(params[:item_id])
  end

  def show
    @item = Item.find(params[:item_id])
  end

  def create
    @item = Item.find(params[:item_id])
    @item.attributes = params[:item]

    if @item.request_carrier_pickup!
      flash[:notice] = "Carrier Pickup scheduled!"
      redirect_to [:activity, current_user]
    else
      flash[:notice] = "There was an error scheduling your pickup"
      render :new
    end
  end
end
