class RemoveUnusedFields < ActiveRecord::Migration
  def self.up
    drop_table :shipments
    remove_column :items, :order_id
    remove_column :orders, :first_name
    remove_column :orders, :last_name
    remove_column :orders, :shipping_address_id
  end

  def self.down
  end
end
