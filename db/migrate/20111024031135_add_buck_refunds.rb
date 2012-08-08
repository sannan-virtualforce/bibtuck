class AddBuckRefunds < ActiveRecord::Migration
  def self.up
    create_table :buck_refunds do |t|
      t.references :item
      t.references :user
      t.text :comment
      t.string :reason
      t.integer :outcome_cd
      t.timestamps
    end
  end

  def self.down
    drop_table :buck_refunds
  end
end
