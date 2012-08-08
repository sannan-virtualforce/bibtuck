class ChangeColumnBibbedItemsCountOnUsers < ActiveRecord::Migration
  def self.up
    change_column :users, :bibbed_items_count, :integer, :default => 0, :null => false
  end

  def self.down
    change_column :users, :bibbed_items_count, :integer
  end
end
