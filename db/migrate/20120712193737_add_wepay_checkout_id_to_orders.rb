class AddWepayCheckoutIdToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :wepay_checkout_id, :integer
  end

  def self.down
    remove_column :orders, :wepay_checkout_id
  end
end
