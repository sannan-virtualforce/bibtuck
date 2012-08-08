class AddTemplateToNotifications < ActiveRecord::Migration
  def self.up
    add_column :notifications, :template, :string
  end

  def self.down
    remove_column :notifications, :template
  end
end
