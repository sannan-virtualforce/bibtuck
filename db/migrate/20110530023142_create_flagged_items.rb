class CreateFlaggedItems < ActiveRecord::Migration
  def self.up
    create_table :flagged_items do |t|
      t.references :item
      t.references :user
      t.string :comment
      t.timestamps
    end
  end

  def self.down
    drop_table :flagged_items
  end
end
