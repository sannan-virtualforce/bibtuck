class CreateCartItems < ActiveRecord::Migration
  def self.up
    create_table :cart_items do |t|
      t.references :cart
      t.references :item

      t.timestamps
    end
    add_index :cart_items, :item_id, :unique => true
  end

  def self.down
    drop_table :cart_items
  end
end
