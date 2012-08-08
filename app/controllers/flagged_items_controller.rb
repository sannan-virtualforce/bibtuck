class FlaggedItemsController < ApplicationController
  before_filter :authenticate_user!

  def new
    @item = Item.find(params[:item_id])
    @flagged_item = FlaggedItem.new(:item => @item)
    render :layout => false
  end

  def create
    @flagged_item = FlaggedItem.new(params[:flagged_item])
    @flagged_item.user = current_user
    @flagged_item.save
    render :layout => false
  end
end
