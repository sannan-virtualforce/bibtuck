class AddTimestampsToAddresses < ActiveRecord::Migration
  def self.up
    add_column(:addresses, :created_at, :timestamp)
    add_column(:addresses, :updated_at, :timestamp)
  end

  def self.down
    remove_column(:addresses, :updated_at)
    remove_column(:addresses, :created_at)
  end
end
