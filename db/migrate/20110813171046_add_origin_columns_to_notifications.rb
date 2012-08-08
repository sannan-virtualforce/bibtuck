class AddOriginColumnsToNotifications < ActiveRecord::Migration
  def self.up
    add_column :notifications, :origin_type, :string
    add_column :notifications, :origin_id, :integer
  end

  def self.down
    remove_column :notifications, :origin_id
    remove_column :notifications, :origin_type
  end
end
