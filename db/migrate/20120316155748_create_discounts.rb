class CreateDiscounts < ActiveRecord::Migration
  def self.up
    create_table :discounts do |t|
      t.references :order
      t.string :discount_type
      t.string :code
      t.timestamps
    end
  end

  def self.down
    drop_table :discounts
  end
end
