class AddAddressToShippingBoxDelivery < ActiveRecord::Migration
  def self.up
    add_column :shipping_box_deliveries, :address_id, :integer
  end

  def self.down
    remove_column :shipping_box_deliveries, :address_id
  end
end
