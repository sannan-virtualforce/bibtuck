module NotificationsHelper

  def notifications_link(show_all=true)
    out = ''
    return out unless current_user
    count = current_user.unread_notifications_count
    text = count > 0 ? "Notifications (#{count})" : 'Notifications'
    out << link_to(text, notifications_path)
    if show_all && count > 0
      out << link_to('See all', notifications_path)
    end
    raw out
  end

  def notification_text(notification)
    raw case notification.template
    when 'new_user' then
      if current_user == notification.user
        "Welcome to our little community! You get #{BuckTransaction::POINTS[:new_user]} bucks for becoming a member. Need some pointers? Check out our #{link_to 'How it Works', page_path('how_it_works')} page."
      end
    when 'founding_member' then
      "Congratulations, you have received Founding Member Status! #{link_to 'View Profile', current_user}"
    when 'new_follow' then
      follow = notification.origin
      "#{link_to follow.follower.display_name, follow.follower} is now following you"
    when 'buck_purchase' then
      buck_purchase = notification.origin
      buck_purchase.new_purchase_subject
      "You purchased #{number_to_bucks buck_purchase.bucks}. #{link_to "View your buck balance", [:bucks, current_user]}"
    when 'new_message' then
      sender = notification.origin.user
      "You have a new message from #{link_to sender.display_name, sender}. Click #{link_to 'here', user_conversation_path(current_user, notification.origin.conversation)} to view message."
    when 'invitation' then
      invited_user = notification.subject
      inviter = notification.user
      "Thanks for inviting #{link_to invited_user.display_name, invited_user} to join Bib + Tuck! You get #{BuckTransaction::POINTS[:invitation]} bucks. #{link_to 'View your Buck Balance', [:bucks, inviter]}"
    when 'tucked_seller'
      item = notification.subject
      buyer = item.order.try(:user)
      "Your #{link_to item.name, item} has been tucked by #{link_to buyer.display_name, buyer}. #{link_to('Print Shipping Label', shipping_label_item_path(item))}"
    when 'shipped_item'
      item = notification.subject
      seller = notification.actor
      order_item = notification.origin
      "Good news! #{link_to seller.display_name, seller} has shipped your #{link_to item.name, item}." +
        (order_item.tracked?  ? " Click #{link_to 'here', order_item.tracking_url, :target => '_blank'} to track your package." : '')
    when 'delivered_item'
      item = notification.subject
      seller = notification.actor
      "The #{link_to item.name, item} you ordered from #{link_to seller.display_name, seller} has been delivered. Rate #{seller.display_name} #{link_to 'here', new_user_experience_path(seller, :item_id => item.id)}."
    when 'buck_refund_request'
      item = notification.subject.item
      requester = notification.subject.user
      "#{requester.display_name} has requested a buck-back for the #{link_to item.name, item}. #{link_to 'View Request Details', [:edit, item, item.buck_refund]}"
    when 'buck_refund_rejected'
      item = notification.subject.item
      "Your buck-back request for the #{link_to item.name, item} has been rejected by #{link_to item.user.name, item}."
    when 'buck_refund_accepted'
      item = notification.subject.item
      requester = notification.user
      "#{link_to item.user.name, item.user} accepted your buck-back request for #{link_to item.name, item}. #{link_to 'View your buck balance', [:bucks, requester]}"
    when 'credit'
      amount = notification.subject.bucks
      if amount < 0
        "Uh oh! Someone at the B+T offices removed #{amount.abs} bucks from your account"
      else
        "Congrats! You've received #{amount} bonus bucks because we think you are fabbity fab. View my #{link_to 'activity', activity_user_path(notification.user)}."
      end
    when 'first_bib'
      "We've added #{notification.origin.delta} bucks to your account for bibbing your first item. Wasn't that easy? #{link_to 'Keep bibbing', new_item_path}."
    when 'added_photo'
      curator = notification.actor
      "A saved photo was added for you by #{curator.display_name}"
    when 'rating'
      rater =  notification.actor
      item = notification.subject.item
      "#{link_to rater.username, rater} has rated your #{link_to item.name, item}. #{link_to 'View Your Rating', [notification.subject.user, :experiences]}"
    end
  end
end
