class ChangeShippingBoxSizeForItem < ActiveRecord::Migration
  def self.up
    change_column :items, :shipping_box_size, :string, :null => false, :default => 'a'
  end

  def self.down
    change_column :items, :shipping_box_size, :string
  end
end
