module BuckTransactionsHelper
  def reason_for(transaction)
    final = case transaction.reason
    when 'invitation'
      "You earned when #{link_to transaction.reference.name, transaction.reference} signed up"
    when 'buck_refund_seller'
      "You accepted a buck refund request from #{link_to transaction.reference.user.display_name, transaction.reference.user} for #{link_to transaction.reference.item.name, transaction.reference.item}"
    when 'buck_refund_buyer'
      seller = transaction.reference.item.user
      "#{link_to seller.display_name, seller} accepted your buck-back request for #{link_to transaction.reference.item.name, transaction.reference.item}"
    when 'buck_purchase'
      "You bought these bucks"
    when 'tuck_buyer'
      items = transaction.reference.items.map do |item|
        link_to item.name, item
      end
      "You tucked #{items.join(', ')}"
    when 'tuck_seller'
      item = transaction.reference.items.select { |i| i.user == current_user }.first
      "You earned when #{link_to transaction.reference.user.display_name, transaction.reference.user} tucked your #{link_to item.name, item}"
    when 'new_user'
      'Just for becoming a member'
    when 'first_bib'
      'We gave you for bibbing your first item'
    when 'credit'
      bucks = transaction.delta
      if bucks > 0
        "We gave you ... because we think you are fabbity fab"
      else
        "Someone in the B+T offices removed bucks from your account"
      end
    end

    raw final
  end
end
