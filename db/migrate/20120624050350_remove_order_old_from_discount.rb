class RemoveOrderOldFromDiscount < ActiveRecord::Migration
  def self.up
    Discount.where('order_old is not null').each do |discount|
      order = Order.find(discount.order_old)
      order.update_attribute :discount, discount
    end
    remove_column :discounts, :order_old
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
