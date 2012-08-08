class CreateShipments < ActiveRecord::Migration
  def initialize
    super()
  end

  def self.up
    create_table :shipments do |t|
      t.references :item
      t.string :seller_addr_first_name
      t.string :seller_addr_last_name
      t.string :seller_addr_street_line1
      t.string :seller_addr_street_line2
      t.string :seller_addr_city
      t.string :seller_addr_state
      t.string :seller_addr_zipcode
      t.string :seller_addr_phone
      t.string :buyer_addr_first_name
      t.string :buyer_addr_last_name
      t.string :buyer_addr_street_line1
      t.string :buyer_addr_street_line2
      t.string :buyer_addr_city
      t.string :buyer_addr_state
      t.string :buyer_addr_zipcode
      t.string :buyer_addr_phone
      t.string :shipping_label
      t.string :tracking_number
      t.string :state
      t.string :last_shipping_status_msg

      t.timestamps
    end
    Order.all.each do |order|
      order.items.each do |item|
        shipment = Shipment.new(:item => item)
        shipment.seller_addr = item.shipping_from_address
        shipment.buyer_addr = order.shipping_address
        if item.tracking_number.present?
          shipment.tracking_number = item.tracking_number
        end
        shipment.save!
      end
    end
  end

  def self.down
    drop_table :shipments
  end
end
