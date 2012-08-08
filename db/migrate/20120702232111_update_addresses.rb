class UpdateAddresses < ActiveRecord::Migration
  def self.up

    say "updating addresses for users"
    User.where('last_sign_in_at is not null').each do |user|
      unless user.primary_shipping_address
        if user.shipping_addresses.count > 0
          user.shipping_addresses.first.update_attribute :is_primary,  true
        else
          say "  user #{user.display_name} (#{user.id}) doesn't have any addresses"
        end
      end
    end

    say "updating addresses for items"
    Item.all.each do |item|
      unless item.shipping_from_address
        primary = item.user.primary_shipping_address || item.user.shipping_addresses.first
        if primary
          item.update_attribute :shipping_from_address, primary
        else
          say "  error processing item #{item.id} - can't find address for user: #{item.user.display_name} (#{item.user.id})" 
        end
      end
    end

    say "updating addresses for orders"
    Order.all.each do |order|
      unless order.shipping_address
        primary = order.user.primary_shipping_address || order.user.shipping_addresses.first
        if primary
          order.update_attribute :shipping_address, primary
        else
          say "  error processing order #{order.id} - can't find address for user: #{order.user.display_name} (#{order.user.id})"
        end
      end
    end
  end

  def self.down
  end
end
