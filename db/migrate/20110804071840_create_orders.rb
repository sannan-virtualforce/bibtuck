class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.references :user
      t.integer :bucks_total
      t.integer :amount_in_cents
      t.string :first_name
      t.string :last_name
      t.string :express_token
      t.string :express_payer_id
      t.text :response
      t.string :ip_address
      t.timestamps
    end
  end

  def self.down
    drop_table :orders
  end
end
