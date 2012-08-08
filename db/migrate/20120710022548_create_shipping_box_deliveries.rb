class CreateShippingBoxDeliveries < ActiveRecord::Migration
  def self.up
    create_table :shipping_box_deliveries do |t|
      t.references :user
      t.string :box_size
      t.integer :amount, :default => 0, :null => false
      t.timestamp :requested_at
      t.timestamp :sent_at

      t.timestamps
    end
    add_index :shipping_box_deliveries, [:user_id, :box_size], :unique => true
  end

  def self.down
    drop_table :shipping_box_deliveries
  end
end
