class AddOrderToItems < ActiveRecord::Migration
  def self.up
    add_column(:items, :order_id, :integer)
  end

  def self.down
    remove_column(:items, :order_id)
  end
end
