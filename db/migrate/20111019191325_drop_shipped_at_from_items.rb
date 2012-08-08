class DropShippedAtFromItems < ActiveRecord::Migration
  def self.up
    remove_column(:items, :shipped_at)
  end

  def self.down
    add_column(:items, :shipped_at, :datetime)
  end
end
