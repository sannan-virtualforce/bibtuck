class UpdateDiscount < ActiveRecord::Migration
  def self.up
    add_column :discounts, :total_uses, :integer
    rename_column :discounts, :order_id, :order_old
    add_column :orders, :discount_id, :integer
    add_index :discounts, :code, :unique => true
  end

  def self.down
    remove_column :orders, :discount_id
    rename_column :discounts, :order_old, :order_id
    remove_column :discounts, :total_uses
    remove_index :discounts, :code
  end
end
