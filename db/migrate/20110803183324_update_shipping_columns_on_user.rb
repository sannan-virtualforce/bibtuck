class UpdateShippingColumnsOnUser < ActiveRecord::Migration
  def self.up
    remove_column(:users, :pickup_address_id)
    remove_column(:users, :delivery_address_id)
    add_column(:addresses, :is_primary, :boolean, :default => false, :null => false)
    add_column(:addresses, :user_id, :integer, :null => false)
  end

  def self.down
    remove_column(:addresses, :is_primary)
    rename_column(:users, :delivery_address_id)
    add_column(:users, :pickup_address_id)
  end
end
