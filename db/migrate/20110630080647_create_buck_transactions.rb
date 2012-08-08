class CreateBuckTransactions < ActiveRecord::Migration
  def self.up
    create_table :buck_transactions do |t|
      t.integer :reference_id
      t.string :reference_type
      t.integer :delta
      t.timestamps
    end
  end

  def self.down
    drop_table :buck_transactions
  end
end
