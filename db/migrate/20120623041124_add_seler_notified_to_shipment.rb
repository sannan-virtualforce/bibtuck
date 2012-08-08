class AddSelerNotifiedToShipment < ActiveRecord::Migration
  def self.up
    add_column :shipments, :seller_notified, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :shipments, :seller_notified
  end
end
