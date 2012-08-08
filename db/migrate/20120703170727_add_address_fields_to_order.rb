class AddAddressFieldsToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :to_addr_first_name, :string
    add_column :orders, :to_addr_last_name, :string
    add_column :orders, :to_addr_street_line1, :string
    add_column :orders, :to_addr_street_line2, :string
    add_column :orders, :to_addr_city, :string
    add_column :orders, :to_addr_state, :string
    add_column :orders, :to_addr_zipcode, :string
    add_column :orders, :to_addr_phone, :string
    say "copying address data into new fields ..."
    Order.all.each do |order|
      order.to_addr = order.shipping_address
      unless order.save
        say "  error saving order: #{order.id}"
        order.errors.full_messages.each do |msg|
          say "   > #{msg}"
        end
      end
    end
  end

  def self.down
    remove_column :orders, :to_addr_first_name
    remove_column :orders, :to_addr_last_name
    remove_column :orders, :to_addr_street_line1
    remove_column :orders, :to_addr_street_line2
    remove_column :orders, :to_addr_city
    remove_column :orders, :to_addr_state
    remove_column :orders, :to_addr_zipcode
    remove_column :orders, :to_addr_phone
  end
end
