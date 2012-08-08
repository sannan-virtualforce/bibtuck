class AddFieldsToOrder < ActiveRecord::Migration
  def self.up
    add_column(:orders, :shipping_address_id, :integer)
    add_column(:orders, :transaction_fee_in_cents, :integer)
    add_column(:orders, :shipping_cost_in_cents, :integer)
    add_column(:orders, :is_complete, :boolean)
  end

  def self.down
    remove_column(:orders, :is_complete)
    remove_column(:orders, :shipping_cost_in_cents)
    remove_column(:orders, :transaction_fee_in_cents)
    remove_column(:orders, :shipping_address_id)
  end
end
