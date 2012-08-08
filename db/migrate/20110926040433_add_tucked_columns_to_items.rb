class AddTuckedColumnsToItems < ActiveRecord::Migration
  def self.up
    add_column(:items, :tucked_at, :timestamp)
  end

  def self.down
    remove_column(:items, :tucked_at)
  end
end
