class RenameNotifiableToSubjectOnNotifications < ActiveRecord::Migration
  def self.up
    rename_column :notifications, :notifiable_type, :subject_type
    rename_column :notifications, :notifiable_id,   :subject_id
  end

  def self.down
    rename_column :notifications, :subject_type, :notifiable_type
    rename_column :notifications, :subject_id,   :notifiable_id
  end
end
