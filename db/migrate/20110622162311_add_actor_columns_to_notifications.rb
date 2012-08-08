class AddActorColumnsToNotifications < ActiveRecord::Migration
  def self.up
    add_column :notifications, :actor_type, :string
    add_column :notifications, :actor_id, :integer
  end

  def self.down
    remove_column :notifications, :actor_id
    remove_column :notifications, :actor_type
  end
end
