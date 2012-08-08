class AddToAddrIdToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :to_addr_id, :integer
  end

  def self.down
    remove_column :orders, :to_addr_id
  end
end
