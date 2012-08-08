class UpdateItemState < ActiveRecord::Migration
  def self.up
    Item.update_all({:state => :shipping}, {:state => [:pending_shipment, :pickup_requested]})
  end

  def self.down
  end
end
