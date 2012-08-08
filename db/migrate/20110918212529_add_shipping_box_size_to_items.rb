class AddShippingBoxSizeToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :shipping_box_size, :string
  end

  def self.down
    remove_column :items, :shipping_box_size
  end
end
