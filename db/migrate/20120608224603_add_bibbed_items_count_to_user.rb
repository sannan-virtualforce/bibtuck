class AddBibbedItemsCountToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :bibbed_items_count, :integer
  end

  def self.down
    remove_column :users, :bibbed_items_count
  end
end
