class CreateNotifications < ActiveRecord::Migration
  def self.up
    create_table :notifications do |t|
      t.integer :user_id
      t.text :body
      t.string :notifiable_type
      t.integer :notifiable_id
      t.datetime :viewed_at
      t.timestamps
    end
  end

  def self.down
    drop_table :notifications
  end
end
