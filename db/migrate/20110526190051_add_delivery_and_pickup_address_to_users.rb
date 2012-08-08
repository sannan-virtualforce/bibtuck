class AddDeliveryAndPickupAddressToUsers < ActiveRecord::Migration
  def self.up
    add_column(:users, :delivery_address_id, :integer)
    add_column(:users, :pickup_address_id, :integer)
  end

  def self.down
    remove_column(:users, :pickup_address_id)
    remove_column(:users, :delivery_address_id)
  end
end
