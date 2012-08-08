class Notifier < ActionMailer::Base
  include ApplicationHelper
  helper :application

  default :from => 'Bib and Tuck <help@bibandtuck.com>'
  CUSTOMER_SERVICE_EMAIL = 'Bib and Tuck <saris@bibandtuck.com>'
  SUBJECT_PREFIX = 'Bib + Tuck'

  def flagged_item(flagged_item)
    @flagged_item = flagged_item
    @item = @flagged_item.item
    mail :to => CUSTOMER_SERVICE_EMAIL, :subject => "Item #{@item.id} flagged for removal"
  end

  def buck_refund_request(request_id)
    @buck_refund = BuckRefund.find(request_id)
    @requester = @buck_refund.user
    @item = @buck_refund.item
    mail :to => @item.user.email, :subject => "#{SUBJECT_PREFIX} Uh-oh, buck refund request"
  end

  def shipped_item(order_item)
    @buyer = order_item.buyer
    @tracking_number = order_item.tracking_number
    @tracking_url = order_item.tracking_url
    @item = order_item.item
    mail :to => @buyer.email, :subject => "Your Bib + Tuck Order Has Shipped"
  end

  def feedback_message(feedback_message)
    @feedback_message = feedback_message
    mail :to => CUSTOMER_SERVICE_EMAIL, :subject => "New customer feedback" do |format|
      format.html { render :layout => false }
    end
  end

  def buck_refund_rejected(request)
    @item = request.item
    @buck_refund = request
    mail :to => CUSTOMER_SERVICE_EMAIL, :subject => "Someone has rejected a refund for an order." do |format|
      format.html { render :layout => false }
    end
  end

  def invitation_accepted(user_id)
    @new_user = User.find(user_id)
    @inviter = @new_user.invited_by
    mail :to => @inviter.email, :subject => "We like your friends, we like you"
  end

  def welcome_user(user_id)
    @user = User.find_by_id(user_id)
    return nil unless @user
    mail :to => @user.email, :subject => "Welcome to Bib + Tuck"
  end

  def new_follower(follow_id)
    @follow = Follow.find(follow_id)
    return nil unless @follow.present?
    return nil unless @follow.following.send_new_follow_notification?
    mail :to => @follow.following.email, :subject => "Someone thinks you're a great tuck."
  end

  def buck_purchase(buck_purchase_id)
    purchase = BuckPurchase.find_by_id(buck_purchase_id)
    return nil unless purchase
    return nil unless purchase.user.send_buck_purchase_notification?
    mail :to => purchase.user.email, :subject => "#{SUBJECT_PREFIX} #{purchase.new_purchase_subject}"
  end

  def new_message(message_id)
    @message = Message.find_by_id(message_id)
    return nil unless @message
    @user = @message.recipient
    mail :to => @user.email, :subject => "#{SUBJECT_PREFIX} #{@message.user.display_name} sent you a message"
  end

  def tucked_for_seller(order_item)
    return nil unless order_item
    @item = order_item.item
    @seller = order_item.seller
    @buyer = order_item.buyer
    if order_item.shipping_label.present?
      attachments["shipping_label_#{@item.id}.pdf"] = File.read(File.join(OrderItem.shipping_labels_path, order_item.shipping_label))
    end
    mail :to => @seller.email, :subject => "Your #{@item.name} was tucked!"
  end

  def tucked_for_buyer(order)
    @order = order
    return nil unless @order
    mail :to => @order.user.email, :subject => "#{SUBJECT_PREFIX} Order Confirmaiton"
  end

  def notify_seller_to_ship(item_id)
    @item = Item.find(item_id)
    return nil unless @item || @item.order
    @seller = @item.user
    mail :to => @seller.email, :subject => "Ship your item, you stylish mother tucker"
  end

  def editors_pick(item_id)
    @item = Item.find(item_id)
    return nil unless @item.present?
    mail :from => CUSTOMER_SERVICE_EMAIL, :to => @item.user.email, :subject => "Your #{@item.name} is as an Editor's Pick!"
  end
end
