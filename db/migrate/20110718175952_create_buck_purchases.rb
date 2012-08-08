class CreateBuckPurchases < ActiveRecord::Migration
  def self.up
    create_table :buck_purchases do |t|
      t.references :user
      t.string :first_name
      t.string :last_name
      t.integer :bucks, :null => false
      t.integer :amount_in_cents, :null => false
      t.string :express_token
      t.string :express_payer_id
      t.text :response
      t.string :ip_address
      t.timestamps
    end
  end

  def self.down
    drop_table :buck_purchases
  end
end
