class BuckPurchaseObserver < ActiveRecord::Observer

  def after_create(buck_purchase)
    Notification.create(
      :template => 'buck_purchase',
      :user     => buck_purchase.user,
      :subject  => buck_purchase,
      :actor    => buck_purchase.user,
      :origin   => buck_purchase
    )
  end

end
