class BuckRefundsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_item

  def accept
    @buck_refund = BuckRefund.find(params[:id])
    @buck_refund.outcome = :accepted
    render :layout => false
  end

  def reject
    @buck_refund = BuckRefund.find(params[:id])
    @buck_refund.outcome = :rejected
    render :layout => false
  end

  def show
    @buck_refund = BuckRefund.find(params[:id])
    redirect_if_completed
  end

  def new
    @buck_refund = current_user.buck_refunds.new
    redirect_if_completed @item.buck_refund 
  end

  def edit
    @buck_refund = BuckRefund.find(params[:id])
    redirect_if_completed
  end

  def update
    @buck_refund = BuckRefund.find(params[:id])
    @buck_refund.attributes = params[:buck_refund]
    if @buck_refund.save
      flash[:notice] = "Thank you! Your Buck refund request has been updated."
      redirect_to activity_user_path(current_user)
    end
  end

  def thank_you
    @buck_refund = BuckRefund.find(params[:id])
  end

  def create
    @buck_refund = current_user.buck_refunds.new(params[:buck_refund])
    @buck_refund.item = @item

    if @buck_refund.save
      redirect_to thank_you_item_buck_refund_path(@item, @buck_refund)
    else
      flash[:notice] = "There was an error creating your buck refund request: #{@buck_refund.errors.inspect}."
      render :new
    end
  end

  private
    def find_item
      @item = Item.find(params[:item_id])
    end

    def redirect_if_completed(refund = nil)
      refund ||= @buck_refund
      if refund.accepted? || refund.rejected?
        flash[:notice] = "This buck refund has already been accepted or rejected."
        redirect_to activity_user_path(current_user)
      end
    end
end
