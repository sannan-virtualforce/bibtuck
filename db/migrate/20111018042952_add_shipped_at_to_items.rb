class AddShippedAtToItems < ActiveRecord::Migration
  def self.up
    add_column(:items, :shipped_at, :datetime)
    add_column(:items, :tracking_number, :string)
    add_column(:items, :carrier_pickup_date, :date)
    add_column(:items, :carrier_pickup_confirmation, :string)
  end

  def self.down
    remove_column(:items, :carrier_pickup_confirmation)
    remove_column(:items, :carrier_pickup_date)
    remove_column(:items, :tracking_number)
    remove_column(:items, :shipped_at)
  end
end
