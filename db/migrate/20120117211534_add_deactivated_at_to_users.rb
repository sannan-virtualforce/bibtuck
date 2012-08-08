class AddDeactivatedAtToUsers < ActiveRecord::Migration
  def self.up
    add_column(:users, :deactivated_at, :timestamp)
  end

  def self.down
    remove_column(:users, :deactivated_at)
  end
end
