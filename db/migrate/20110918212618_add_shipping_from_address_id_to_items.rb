class AddShippingFromAddressIdToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :shipping_from_address_id, :integer
  end

  def self.down
    remove_column :items, :shipping_from_address_id
  end
end
