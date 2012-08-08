class RemoveEmailIndexOnSubscribers < ActiveRecord::Migration
  def self.up
    remove_index :subscribers, :email
  end

  def self.down
    add_index :subscribers, :email, :unique => true
  end
end
