class AddSpamToMessages < ActiveRecord::Migration
  def self.up
    add_column(:messages, :spam, :boolean, :default => false, :null => false)
  end

  def self.down
    remove_column(:messages, :spam)
  end
end
