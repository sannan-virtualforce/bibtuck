class AddCarrierFieldsToItems < ActiveRecord::Migration
  def self.up
    add_column(:items, :carrier_pickup_location, :string)
  end

  def self.down
    remove_column(:items, :carrier_pickup_location)
  end
end
