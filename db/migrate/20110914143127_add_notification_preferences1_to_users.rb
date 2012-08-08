class AddNotificationPreferences1ToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :send_new_follow_notification, :boolean, :null => false, :default => true
    add_column :users, :send_buck_purchase_notification, :boolean, :null => false, :default => true
  end

  def self.down
    remove_column :users, :send_buck_purchase_notification
    remove_column :users, :send_new_follow_notification
  end
end
