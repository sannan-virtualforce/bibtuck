class AddEditorsPickToItems < ActiveRecord::Migration
  def self.up
    add_column(:items, :editors_pick, :boolean)
  end

  def self.down
    remove_column(:items, :editors_pick)
  end
end
