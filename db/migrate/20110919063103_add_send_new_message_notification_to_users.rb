class AddSendNewMessageNotificationToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :send_new_message_notification, :boolean, :default => true, :null => false
    add_index :users, :send_new_message_notification
  end

  def self.down
    remove_column :users, :send_new_message_notification
  end
end
