class CreateOrderItems < ActiveRecord::Migration
  def self.up
    create_table :order_items do |t|
      t.references :item
      t.references :order
      t.string :from_addr_first_name
      t.string :from_addr_last_name
      t.string :from_addr_street_line1
      t.string :from_addr_street_line2
      t.string :from_addr_city
      t.string :from_addr_state
      t.string :from_addr_zipcode
      t.string :from_addr_phone
      t.string :shipping_status
      t.string :last_shipping_status_message
      t.string :shipping_label
      t.string :tracking_number
      t.datetime :shipped_at
      t.datetime :delivered_at
      t.integer :seller_notified_to_ship, :default => 0, :null => false

      t.timestamps
    end
    add_index :order_items, :item_id, :unique => true

    say "populating order items with data"
    Order.where('is_complete is not null').each do |order|
      order.items.each do |item|
        order_item = order.order_items.build(:item => item)
        order_item.from_addr = item.shipping_from_address
        if item.shipment
          order_item.shipping_status = item.shipment.state
          order_item.last_shipping_status_message = item.shipment.last_shipping_status_msg
          order_item.shipping_label = item.shipment.shipping_label
          order_item.tracking_number = item.shipment.tracking_number
          # order_item.shipped_at = item.shipment.shipped_at
          # causes error for some reason
          # order_item.delivered_at = item.shipment.delivered_at
          order_item.seller_notified_to_ship = item.shipment.seller_notified
        end
        unless order_item.save
          say "  error saving Order Item for order: #{order.id} and item: #{item.id}"
          order_item.errors.full_messages.each do |msg|
            say "   > #{msg}"
          end
        end
      end
    end
  end

  def self.down
    drop_table :order_items
  end
end

