class AddWepayCheckoutIdToBuckPurchases < ActiveRecord::Migration
  def self.up
    add_column :buck_purchases, :wepay_checkout_id, :integer
  end

  def self.down
    remove_column :buck_purchases, :wepay_checkout_id
  end
end
