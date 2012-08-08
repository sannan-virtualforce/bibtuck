class RemoveRefundRequestedItemState < ActiveRecord::Migration
  def self.up
    Item.update_all({:state => :shipping}, {:state => :refund_requested})
  end

  def self.down
  end
end
