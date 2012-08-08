class CreateCarts < ActiveRecord::Migration
  def self.up
    create_table :carts do |t|
      t.references :user

      t.timestamps
    end
    add_index :carts, :user_id, :unique => true
  end

  def self.down
    drop_table :carts
  end
end
